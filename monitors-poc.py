#!/usr/bin/env python3

from collections import namedtuple
from dataclasses import dataclass
from pydbus import SessionBus
from typing import List
import xml.etree.ElementTree as ET
from xml.dom.minidom import parseString

session_bus = SessionBus()
dc_proxy = session_bus.get('org.gnome.Mutter.DisplayConfig', '/org/gnome/Mutter/DisplayConfig')
gcs_tuple = dc_proxy.GetCurrentState()

# print('>>>>>>>>>>>>>>>>>>>> gcs_tuple <<<<<<<<<<<<<<<<<<<<')
# print(gcs_tuple[1])

MonitorSpecT = namedtuple('MonitorSpecT', 'connector vendor product serial')
LogicalMonitorRawT = namedtuple('LogicalMonitorRawT', 'x y scale display primary spec_arr opts')
LogicalMonitorT = namedtuple('LogicalMonitorT', 'x y scale display primary spec opts')
MonitorInfoRawT = namedtuple('MonitorInfoRawT', 'spec modes_arr misc')
MonitorInfoT = namedtuple('MonitorInfoT', 'spec modes misc')
ModeT = namedtuple('ModeT', 'modespec width height refresh scale scales_available opts')
CurrentStateT = namedtuple('CurrentStateT', 'ct infos config render')

def get_logical_monitor(tup):
    lm_raw = LogicalMonitorRawT(*tup)
    monitor_spec = None if len(lm_raw.spec_arr) == 0 else MonitorSpecT(*lm_raw.spec_arr[0])
    return LogicalMonitorT(lm_raw.x, lm_raw.y, lm_raw.scale, lm_raw.display, lm_raw.primary, monitor_spec, lm_raw.opts)

def get_logical_monitors(tup):
    cs = CurrentStateT(*tup)
    return [get_logical_monitor(mon) for mon in cs.config]

logical_monitors = get_logical_monitors(gcs_tuple)

# print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> logical_monitors <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
# print(logical_monitors)

def get_monitor_info(tup):
    mi_raw = MonitorInfoRawT(*tup)
    modes = [ModeT(*m) for m in mi_raw.modes_arr]
    spec = MonitorSpecT(*mi_raw.spec)
    return MonitorInfoT(spec, modes, mi_raw.misc)

def get_monitor_infos(tup):
    cs = CurrentStateT(*tup)
    return [get_monitor_info(mon) for mon in cs.infos]

monitor_infos = get_monitor_infos(gcs_tuple)

# print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> monitor_infos <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
# print(monitor_infos)

def xml_prop(name, value):
    el = ET.Element(name)
    el.text = value
    return el

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
        width = xml_prop('width', str(self.width))
        height = xml_prop('height', str(self.height))
        rate = xml_prop('rate', str(self.rate))
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
        x = xml_prop('x', str(self.x))
        y = xml_prop('y', str(self.y))
        scale = xml_prop('scale', str(int(self.scale)))
        primary = xml_prop('primary', str(self.primary))
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
        for lm in self.configuration:
            configuration.append(lm.to_xml())
        monitors = ET.Element('monitors', version='2')
        monitors.append(configuration)
        return monitors

lm_list = []
for (lm, info) in zip(logical_monitors, monitor_infos):
    monitorspec = MonitorSpec(info.spec.connector, info.spec.vendor, info.spec.product, info.spec.serial)
    active_mode = info.modes[0]
    mode = Mode(active_mode.width, active_mode.height, active_mode.refresh)
    monitor = Monitor(monitorspec, mode)
    logicalmonitor = LogicalMonitor(lm.x, lm.y, lm.scale, lm.primary, monitor)
    lm_list.append(logicalmonitor)
monitors = Monitors(lm_list)
monitors_dom = parseString(ET.tostring(monitors.to_xml(), encoding='unicode'))

print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FINAL <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
print(monitors_dom.toprettyxml(indent='  '))
