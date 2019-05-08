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
composer card delete -c bob@bnastorage
composer card delete -c alice@bnstorage

rm -rv alice
rm -rv bob


echo "INSERT_ORG1_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/ca.crt > ./tmp/INSERT_ORG1_CA_CERT

echo "INSERT_ORG2_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/ca.crt > ./tmp/INSERT_ORG2_CA_CERT

echo "INSERT_ORDERER_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/hospital.com/orderers/orderer.hospital.com/tls/ca.crt > ./tmp/INSERT_ORDERER_CA_CERT


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
                "orderer.hospital.com"
            ],
            "peers": {
                "peer0.org1.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.hospital.com": {
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
                "peer0.org1.hospital.com",
                "peer1.org1.hospital.com"
            ],
            "certificateAuthorities": [
                "ca.org1.hospital.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.hospital.com",
                "peer1.org2.hospital.com"
            ],
            "certificateAuthorities": [
                "ca.org2.hospital.com"
            ]
        }
    },
    "orderers": {
        "orderer.hospital.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.hospital.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.hospital.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.hospital.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.hospital.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.hospital.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.hospital.com": {
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
                "orderer.hospital.com"
            ],
            "peers": {
                "peer0.org1.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.hospital.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.hospital.com": {
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
                "peer0.org1.hospital.com",
                "peer1.org1.hospital.com"
            ],
            "certificateAuthorities": [
                "ca.org1.hospital.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.hospital.com",
                "peer1.org2.hospital.com"
            ],
            "certificateAuthorities": [
                "ca.org2.hospital.com"
            ]
        }
    },
    "orderers": {
        "orderer.hospital.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.hospital.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.hospital.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.hospital.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.hospital.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.hospital.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.hospital.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.hospital.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

ORG1ADMIN="./crypto-config/peerOrganizations/org1.hospital.com/users/Admin@org1.hospital.com/msp"
ORG2ADMIN="./crypto-config/peerOrganizations/org2.hospital.com/users/Admin@org2.hospital.com/msp"

composer card create -p ./byfn-network-org1.json -u PeerAdmin -c $ORG1ADMIN/signcerts/A*.pem -k $ORG1ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org1.card
composer card create -p ./byfn-network-org2.json -u PeerAdmin -c $ORG2ADMIN/signcerts/A*.pem -k $ORG2ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org2.card

composer card import -f PeerAdmin@byfn-network-org1.card --card PeerAdmin@byfn-network-org1
composer card import -f PeerAdmin@byfn-network-org2.card --card PeerAdmin@byfn-network-org2

composer network install --card PeerAdmin@byfn-network-org1 --archiveFile bnastorage@$VERSION.bna
composer network install --card PeerAdmin@byfn-network-org2 --archiveFile bnastorage@$VERSION.bna

composer identity request -c PeerAdmin@byfn-network-org1 -u admin -s adminpw -d alice
composer identity request -c PeerAdmin@byfn-network-org2 -u admin -s adminpw -d bob

composer network start -c PeerAdmin@byfn-network-org1 -n bnastorage -V $VERSION -o endorsementPolicyFile=./endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem

# create card for alice, as business network admin
composer card create -p ./byfn-network-org1.json -u alice -n bnastorage -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@bnastorage.card

# create card for bob, as business network admin
composer card create -p ./byfn-network-org2.json -u bob -n bnastorage -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@bnastorage.card
