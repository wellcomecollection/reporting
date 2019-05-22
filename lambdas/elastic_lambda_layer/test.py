import sys
import os
from elasticsearch import Elasticsearch

def test():
    assert Elasticsearch is not None

if __name__ == '__main__':
    test()
