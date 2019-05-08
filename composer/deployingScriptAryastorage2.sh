if [ -z ${1} ]; then
	ls | grep bnastorage
	exit
fi

VERSION=$1
ORDERER_HOST=192.168.56.107
ORG1_HOST=192.168.56.108
ORG2_HOST=192.168.56.109

composer card delete -c PeerAdmin@byfn-network-org2
composer card delete -c PeerAdmin@byfn-network-org1
composer card delete -c PeerAdmin@byfn-network-org22
composer card delete -c bob@bnastorage
composer card delete -c alice@bnstorage
composer card delete -c cristi@bnastorage2


rm -rv alice
rm -rv bob
rm -rv cristi

echo "INSERT_ORG1_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.aryastorage.com/peers/peer0.org1.aryastorage.com/tls/ca.crt > ./tmp/INSERT_ORG1_CA_CERT

echo "INSERT_ORG2_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.aryastorage.com/peers/peer0.org2.aryastorage.com/tls/ca.crt > ./tmp/INSERT_ORG2_CA_CERT

echo "INSERT_ORDERER_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/aryastorage.com/orderers/orderer.aryastorage.com/tls/ca.crt > ./tmp/INSERT_ORDERER_CA_CERT


cat << EOF > ./byfn-network-org1.json
{
    "name": "byfn-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "Org1",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "2100",
					"eventHub": "2100",
					"eventReg": "2100"
				},
				"orderer": "2100"
			}
		}
	},
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.aryastorage.com"
            ],
            "peers": {
                "peer0.org1.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.aryastorage.com",
                "peer1.org1.aryastorage.com"
            ],
            "certificateAuthorities": [
                "ca.org1.aryastorage.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.aryastorage.com",
                "peer1.org2.aryastorage.com"
            ],
            "certificateAuthorities": [
                "ca.org2.aryastorage.com"
            ]
        }
    },
    "orderers": {
        "orderer.aryastorage.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.aryastorage.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.aryastorage.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.aryastorage.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.aryastorage.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF


cat << EOF > ./byfn-network-org2.json
{
    "name": "byfn-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "Org2",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "2100",
					"eventHub": "2100",
					"eventReg": "2100"
				},
				"orderer": "2100"
			}
		}
	},
    "channels": {
        "composerchannel": {
            "orderers": [
                "orderer.aryastorage.com"
            ],
            "peers": {
                "peer0.org1.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.aryastorage.com",
                "peer1.org1.aryastorage.com"
            ],
            "certificateAuthorities": [
                "ca.org1.aryastorage.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.aryastorage.com",
                "peer1.org2.aryastorage.com"
            ],
            "certificateAuthorities": [
                "ca.org2.aryastorage.com"
            ]
        }
    },
    "orderers": {
        "orderer.aryastorage.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.aryastorage.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.aryastorage.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.aryastorage.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.aryastorage.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

cat << EOF > ./byfn-network-org2-only.json
{
    "name": "byfn-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "Org2",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "2100",
					"eventHub": "2100",
					"eventReg": "2100"
				},
				"orderer": "2100"
			}
		}
	},
    "channels": {
        "composerchannel2": {
            "orderers": [
                "orderer.aryastorage.com"
            ],
            "peers": {
                "peer0.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.aryastorage.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.aryastorage.com",
                "peer1.org2.aryastorage.com"
            ],
            "certificateAuthorities": [
                "ca.org2.aryastorage.com"
            ]
        }
    },
    "orderers": {
        "orderer.aryastorage.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.aryastorage.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.aryastorage.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org2.aryastorage.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

ORG1ADMIN="./crypto-config/peerOrganizations/org1.aryastorage.com/users/Admin@org1.aryastorage.com/msp"
ORG2ADMIN="./crypto-config/peerOrganizations/org2.aryastorage.com/users/Admin@org2.aryastorage.com/msp"

composer card create -p ./byfn-network-org1.json -u PeerAdmin -c $ORG1ADMIN/signcerts/A*.pem -k $ORG1ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org1.card
composer card create -p ./byfn-network-org2.json -u PeerAdmin -c $ORG2ADMIN/signcerts/A*.pem -k $ORG2ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org2.card
composer card create -p ./byfn-network-org2-only.json -u PeerAdmin -c $ORG2ADMIN/signcerts/A*.pem -k $ORG2ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org22.card

composer card import -f PeerAdmin@byfn-network-org1.card --card PeerAdmin@byfn-network-org1
composer card import -f PeerAdmin@byfn-network-org2.card --card PeerAdmin@byfn-network-org2
composer card import -f PeerAdmin@byfn-network-org22.card --card PeerAdmin@byfn-network-org22

composer network install --card PeerAdmin@byfn-network-org1 --archiveFile bnastorage@$VERSION.bna
composer network install --card PeerAdmin@byfn-network-org2 --archiveFile bnastorage@$VERSION.bna
composer network install --card PeerAdmin@byfn-network-org22 --archiveFile bnastorage2@$VERSION.bna

composer identity request -c PeerAdmin@byfn-network-org1 -u admin -s adminpw -d alice
composer identity request -c PeerAdmin@byfn-network-org2 -u admin -s adminpw -d bob
composer identity request -c PeerAdmin@byfn-network-org22 -u admin -s adminpw -d cristi

composer network start -c PeerAdmin@byfn-network-org1 -n bnastorage -V $VERSION -o endorsementPolicyFile=./endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem
composer network start -c PeerAdmin@byfn-network-org22 -n bnastorage2 -V $VERSION -o endorsementPolicyFile=./endorsement-policy2.json -A cristi -C cristi/admin-pub.pem

# create card for alice, as business network admin
composer card create -p ./byfn-network-org1.json -u alice -n bnastorage -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@bnastorage.card

# create card for bob, as business network admin
composer card create -p ./byfn-network-org2.json -u bob -n bnastorage -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@bnastorage.card

# create card for bob, as business network admin
composer card create -p ./byfn-network-org2-only.json -u cristi -n bnastorage2 -c cristi/admin-pub.pem -k cristi/admin-priv.pem
composer card import -f cristi@bnastorage2.card


