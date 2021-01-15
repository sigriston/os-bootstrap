#!/usr/bin/env python

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

# TODO
DOCUMENTATION = r'''
'''

# TODO
EXAMPLES = r'''
'''

# TODO
RETURN = r'''
'''

from ansible.module_utils.basic import AnsibleModule
from collections import namedtuple
from dataclasses import dataclass
from os.path import isdir, join
from pydbus import SessionBus
from typing import List
import xml.etree.ElementTree as ET
from xml.dom.minidom import parseString


# namedtuples for easy access to the GNOME (Mutter) display config data types
MonitorSpecT = namedtuple('MonitorSpecT', 'connector vendor product serial')
LogicalMonitorRawT = namedtuple('LogicalMonitorRawT', 'x y scale display primary spec_arr opts')
LogicalMonitorT = namedtuple('LogicalMonitorT', 'x y scale display primary spec opts')
MonitorInfoRawT = namedtuple('MonitorInfoRawT', 'spec modes_arr misc')
MonitorInfoT = namedtuple('MonitorInfoT', 'spec modes misc')
ModeT = namedtuple('ModeT', 'modespec width height refresh scale scales_available opts')
CurrentStateT = namedtuple('CurrentStateT', 'ct infos config render')

def get_gcs_tuple():
    session_bus = SessionBus()
    dc_proxy = session_bus.get('org.gnome.Mutter.DisplayConfig', '/org/gnome/Mutter/DisplayConfig')
    return dc_proxy.GetCurrentState()

def get_logical_monitor(tup):
    lm_raw = LogicalMonitorRawT(*tup)
    monitor_spec = None if len(lm_raw.spec_arr) == 0 else MonitorSpecT(*lm_raw.spec_arr[0])
    return LogicalMonitorT(lm_raw.x, lm_raw.y, lm_raw.scale, lm_raw.display, lm_raw.primary, monitor_spec, lm_raw.opts)

def get_logical_monitors(tup):
    cs = CurrentStateT(*tup)
    return [get_logical_monitor(mon) for mon in cs.config]

def get_monitor_info(tup):
    mi_raw = MonitorInfoRawT(*tup)
    modes = [ModeT(*m) for m in mi_raw.modes_arr]
    spec = MonitorSpecT(*mi_raw.spec)
    return MonitorInfoT(spec, modes, mi_raw.misc)

def get_monitor_infos(tup):
    cs = CurrentStateT(*tup)
    return [get_monitor_info(mon) for mon in cs.infos]

def xml_prop(name, value):
    el = ET.Element(name)
    el.text = str(value)
    return el

# dataclasses for XML output
@dataclass
class MonitorSpec:
    connector: str
    vendor: str
    product: str
    serial: str

    def to_xml(self):
        connector = xml_prop('connector', self.connector)
        vendor = xml_prop('vendor', self.vendor)
        product = xml_prop('product', self.product)
        serial = xml_prop('serial', self.serial)
        monitorspec = ET.Element('monitorspec')
        monitorspec.append(connector)
        monitorspec.append(vendor)
        monitorspec.append(product)
        monitorspec.append(serial)
        return monitorspec

@dataclass
class Mode:
    width: int
    height: int
    rate: float

    def to_xml(self):
        width = xml_prop('width', self.width)
        height = xml_prop('height', self.height)
        rate = xml_prop('rate', self.rate)
        mode = ET.Element('mode')
        mode.append(width)
        mode.append(height)
        mode.append(rate)
        return mode

@dataclass
class Monitor:
    monitorspec: MonitorSpec
    mode: Mode

    def to_xml(self):
        monitorspec = self.monitorspec.to_xml()
        mode = self.mode.to_xml()
        monitor = ET.Element('monitor')
        monitor.append(monitorspec)
        monitor.append(mode)
        return monitor

@dataclass
class LogicalMonitor:
    x: int
    y: int
    scale: int
    primary: bool
    monitor: Monitor

    def to_xml(self):
        x = xml_prop('x', self.x)
        y = xml_prop('y', self.y)
        scale = xml_prop('scale', int(self.scale))
        primary = xml_prop('primary', 'yes')
        monitor = self.monitor.to_xml()
        logicalmonitor = ET.Element('logicalmonitor')
        logicalmonitor.append(x)
        logicalmonitor.append(y)
        logicalmonitor.append(scale)
        if self.primary:
            logicalmonitor.append(primary)
        logicalmonitor.append(monitor)
        return logicalmonitor

@dataclass
class Monitors:
    configuration: List[LogicalMonitor]

    def to_xml(self):
        configuration = ET.Element('configuration')
        for lm in sorted(self.configuration, key=lambda m: m.x):
            configuration.append(lm.to_xml())
        monitors = ET.Element('monitors', version='2')
        monitors.append(configuration)
        return monitors

def get_logicalmonitor_list():
    gcs_tuple = get_gcs_tuple()
    logical_monitors = get_logical_monitors()
    lm_list = []
    for (lm, info) in zip(logical_monitors, monitor_infos):
        monitorspec = MonitorSpec(info.spec.connector, info.spec.vendor, info.spec.product, info.spec.serial)
        [preferred_mode] = [mode for mode in info.modes if mode.opts.get('is-preferred')]
        mode = Mode(preferred_mode.width, preferred_mode.height, preferred_mode.refresh)
        monitor = Monitor(monitorspec, mode)
        logicalmonitor = LogicalMonitor(lm.x, lm.y, lm.scale, lm.primary, monitor)
        lm_list.append(logicalmonitor)
    return lm_list

def fix_logicalmonitor_list(serials_l2r, the_primary):
    lm_list = get_logicalmonitor_list()
    l2r_list = []
    current_x = 0
    for serial in serials_l2r:
        [lm] = [lm for lm in lm_list if lm.monitor.monitorspec.serial == serial]
        lm.x = current_x
        lm.primary = serial == the_primary
        current_x = current_x + lm.monitor.mode.width
        l2r_list.append(lm)
    return l2r_list

def make_monitors_xml(pth, serials_l2r, the_primary=None):
    l2r_list = fix_logicalmonitor_list(serials_l2r, the_primary)
    monitors = Monitors(l2r_list)
    monitors_dom = parseString(ET.tostring(monitors.to_xml(), encoding='unicode'))
    monitors_str = monitors_dom.toprettyxml(indent='  ')

    changed = True
    with open(pth, 'r+') as file:
        orig_str = file.read()
        if orig_str == monitors_str:
            changed = False
        else:
            file.write(monitors_str)
    return changed

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='path', required=True, aliases=['name'])
        monitors=dict(type='list', elements='str', required=True),
        primary=dict(type='str', required=False),
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    dir_path = module.params['path']

    try:
        if not isdir(dir_path):
            raise FileNotFoundError(f'Path {dir_path} is not a directory')

        final_path = join(dir_path, 'monitors.xml')
        monitors = module.params['monitors']
        primary = module.params.get('primary')
        result['changed'] = make_monitors_xml(final_path, monitors, primary)
    except Exception as e:
        module.fail_json(msg=str(e), **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
