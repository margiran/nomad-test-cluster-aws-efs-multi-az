#!/usr/bin/env python3

from mmap import PROT_READ
from diagrams import Diagram
from diagrams import Cluster, Diagram, Edge
from diagrams.custom import Custom
from diagrams.aws.compute import EC2
from diagrams.aws.storage import EFS
from diagrams.aws.network import VPCElasticNetworkInterface
from diagrams.onprem.compute import Nomad
from diagrams.onprem.network import Consul
from diagrams.onprem.security import Vault

with Diagram("AWS efs multi AZ Nomad", show=False):
    with Cluster("VPC"):
        with Cluster("availability zone a"):
            with Cluster("Subnet-A"):
                n_server = Nomad("Nomad Server")
                n_client1 = Nomad("Nomad Client 1")
                [ n_server] << n_client1
                mt_a= VPCElasticNetworkInterface("Mount Target az-a")
                [ mt_a ] - n_client1

        with Cluster("availability zone b"):
            with Cluster("Subnet-B"):
                n_client2 = Nomad("Nomad Client 2")
                [ n_server] << n_client2
                mt_b= VPCElasticNetworkInterface("Mount Target az-b")
                [ mt_b ] - n_client2

        efs=EFS("Amazon Elastic File System")
        [ efs] - mt_a
        [ efs] - mt_b