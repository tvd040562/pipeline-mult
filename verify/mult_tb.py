import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random
import queue
import logging

@cocotb.test()
async def test_top(dut):
    clk = Clock(dut.clk, 10, "ns")
    clk.start()
    
    dut.rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    
    expect = queue.Queue()
    actual = queue.Queue()
    
    latency = 0
    for _ in range(2000):
        await RisingEdge(dut.clk)
        aValue = random.randint(0,2**31)
        bValue = random.randint(0,2**31)
        dut.a.value = aValue
        dut.b.value = bValue
        expect.put(aValue * bValue)
        if latency < 6:
            latency = latency + 1
        else:
            actual.put(dut.p.value)
    while actual.qsize() > 0:
        #cocotb.log.info("Expect: %d; Actual: %d", expect.get(), actual.get())
        assert expect.get() == actual.get()
   
    