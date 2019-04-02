# -*-coding:utf-8 -*-

from kazoo.client import KazooClient
import logging
from struct import unpack
import time

from pb.ZooKeeper_pb2 import MetaRegionServer

from dbWiFi import *

logging.basicConfig()

import ConfigParser
#############read from configure#################
config = ConfigParser.ConfigParser()
config.read('/data/wifi/PROD_new/config/config.cfg')
iptable_d1 = config.get('Hbase','iptable_d1')
iptable_d2 = config.get('Hbase','iptable_d2')
iptable_d3 = config.get('Hbase','iptable_d3')
iptable_d4 = config.get('Hbase','iptable_d4')
iptable_d5 = config.get('Hbase','iptable_d5')
iptable_d6 = config.get('Hbase','iptable_d6')
iptable_d7 = config.get('Hbase','iptable_d7')

zkquorum_address = config.get('Hbase','zkquorum')
############################

def hb_master(test=0):
    znode = '/hbase'

    if test == 1:
        ############test
        iptable = {'d1': iptable_d1,
                   'd2': iptable_d2,
                   'd3': iptable_d3,
                   'd4': iptable_d4}

        zkquorum = zkquorum_address

    else:
        iptable = {'d1': iptable_d1,
                   'd2': iptable_d2,
                   'd3': iptable_d3,
                   'd4': iptable_d4,
                   'd5': iptable_d5,
                   'd6': iptable_d6,
                   'd7': iptable_d7}

        zkquorum = zkquorum_address

    zk = KazooClient(hosts=zkquorum, timeout=10.0, logger=logging)
    zk.start()

    rsp, znodestat = zk.get(znode + "/meta-region-server")

    zk.stop()
    zk.close()

    if len(rsp)  == 0:
        return None

    first_byte, meta_length = unpack(">cI", rsp[:5])

    magic = unpack(">I", rsp[meta_length + 5: meta_length + 9])[0]

    if magic != 1346524486:
        return  None

    rsp = rsp[meta_length + 9:]

    meta = MetaRegionServer()
    meta.ParseFromString(rsp)

    print(iptable[str(meta.server.host_name)], meta.server.port)

    redis_pool_thrift = conn_redis_pool(10)
    if test == 1:
        redis_pool_thrift.set('thrift_ip_test', iptable[str(meta.server.host_name)])

    else:
        # redis_pool_thrift.set('thrift_ip', iptable[str(meta.server.host_name)])
        redis_pool_thrift.set('thrift_ip', iptable[str(meta.server.host_name)])

    redis_pool_thrift.connection_pool.disconnect()

    return iptable[str(meta.server.host_name)]

if __name__ == '__main__':

    stime = time.time()
    hb_master(0)
    print(time.time() - stime)
