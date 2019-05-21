import sys
import os
sys.path.insert(0, os.path.abspath('./python'))
from elasticsearch import Elasticsearch

def test():
    assert Elasticsearch is not None

if __name__ == '__main__':
    test()
