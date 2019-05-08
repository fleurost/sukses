if [ -z ${1} ]; then
	ls | grep evote-network
	exit
fi

VERSION=$1
ORDERER_HOST=192.168.56.107
JATIM_HOST=192.168.56.108
JABAR_HOST=192.168.56.109

composer card delete -c PeerAdmin@byfn-network-jabar
composer card delete -c PeerAdmin@byfn-network-jatim
composer card delete -c bob@evote-network
composer card delete -c alice@evote-network
composer card delete -c dyahayu@evote-network
composer card delete -c monitoring1@evote-network
composer card delete -c monitoring2@evote-network
composer card delete -c kandidat1dyahayu@evote-network
composer card delete -c bukanDyahAyu@evote-network
composer card delete -c bukanDyahAyu2@evote-network
rm -rv alice
rm -rv bob
rm dyahayu.card
rm monitoring1.card
rm kandidat1dyahayu.card
rm bukanDyahAyu.card

echo "INSERT_ORG1_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/jatim.evote.com/peers/peer0.jatim.evote.com/tls/ca.crt > ./tmp/INSERT_ORG1_CA_CERT

echo "INSERT_ORG2_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/jabar.evote.com/peers/peer0.jabar.evote.com/tls/ca.crt > ./tmp/INSERT_ORG2_CA_CERT

echo "INSERT_ORDERER_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/evote.com/orderers/orderer.evote.com/tls/ca.crt > ./tmp/INSERT_ORDERER_CA_CERT


cat << EOF > ./byfn-network-jatim.json
{
    "name": "byfn-network-jatim",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "Jatim",
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
                "orderer.evote.com"
            ],
            "peers": {
                "peer0.jatim.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.jatim.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.jabar.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.jabar.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Jatim": {
            "mspid": "JatimMSP",
            "peers": [
                "peer0.jatim.evote.com",
                "peer1.jatim.evote.com"
            ],
            "certificateAuthorities": [
                "ca.jatim.evote.com"
            ]
        },
        "Jabar": {
            "mspid": "JabarMSP",
            "peers": [
                "peer0.jabar.evote.com",
                "peer1.jabar.evote.com"
            ],
            "certificateAuthorities": [
                "ca.jabar.evote.com"
            ]
        }
    },
    "orderers": {
        "orderer.evote.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.jatim.evote.com": {
            "url": "grpcs://${JATIM_HOST}:7051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.jatim.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.jatim.evote.com": {
            "url": "grpcs://${JATIM_HOST}:8051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.jatim.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.jabar.evote.com": {
            "url": "grpcs://${JABAR_HOST}:9051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.jabar.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.jabar.evote.com": {
            "url": "grpcs://${JABAR_HOST}:10051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.jabar.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.jatim.evote.com": {
            "url": "https://${JATIM_HOST}:7054",
            "caName": "ca-jatim",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.jabar.evote.com": {
            "url": "https://${JABAR_HOST}:8054",
            "caName": "ca-jabar",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF


cat << EOF > ./byfn-network-jabar.json
{
    "name": "byfn-network-jabar",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "Jabar",
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
                "orderer.evote.com"
            ],
            "peers": {
                "peer0.jatim.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.jatim.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.jabar.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.jabar.evote.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Jatim": {
            "mspid": "JatimMSP",
            "peers": [
                "peer0.jatim.evote.com",
                "peer1.jatim.evote.com"
            ],
            "certificateAuthorities": [
                "ca.jatim.evote.com"
            ]
        },
        "Jabar": {
            "mspid": "JabarMSP",
            "peers": [
                "peer0.jabar.evote.com",
                "peer1.jabar.evote.com"
            ],
            "certificateAuthorities": [
                "ca.jabar.evote.com"
            ]
        }
    },
    "orderers": {
        "orderer.evote.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.jatim.evote.com": {
            "url": "grpcs://${JATIM_HOST}:7051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.jatim.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.jatim.evote.com": {
            "url": "grpcs://${JATIM_HOST}:8051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.jatim.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.jabar.evote.com": {
            "url": "grpcs://${JABAR_HOST}:9051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.jabar.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.jabar.evote.com": {
            "url": "grpcs://${JABAR_HOST}:10051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.jabar.evote.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.jatim.evote.com": {
            "url": "https://${JATIM_HOST}:7054",
            "caName": "ca-jatim",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.jabar.evote.com": {
            "url": "https://${JABAR_HOST}:8054",
            "caName": "ca-jabar",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF
# 
# JATIMADMIN="./crypto-config/peerOrganizations/jatim.evote.com/users/Admin@jatim.evote.com/msp"
# JABARADMIN="./crypto-config/peerOrganizations/jabar.evote.com/users/Admin@jabar.evote.com/msp"
#
# composer card create -p ./byfn-network-jatim.json -u PeerAdmin -c $JATIMADMIN/signcerts/A*.pem -k $JATIMADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-jatim.card
# composer card create -p ./byfn-network-jabar.json -u PeerAdmin -c $JABARADMIN/signcerts/A*.pem -k $JABARADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-jabar.card
#
# composer card import -f PeerAdmin@byfn-network-jatim.card --card PeerAdmin@byfn-network-jatim
# composer card import -f PeerAdmin@byfn-network-jabar.card --card PeerAdmin@byfn-network-jabar
#
# composer network install --card PeerAdmin@byfn-network-jatim --archiveFile evote-network@$VERSION.bna
# composer network install --card PeerAdmin@byfn-network-jabar --archiveFile evote-network@$VERSION.bna
#
# composer identity request -c PeerAdmin@byfn-network-jatim -u admin -s adminpw -d alice
# composer identity request -c PeerAdmin@byfn-network-jabar -u admin -s adminpw -d bob
#
# composer network start -c PeerAdmin@byfn-network-jatim -n evote-network -V $VERSION -o endorsementPolicyFile=./endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem
#
# # create card for alice, as business network admin
# composer card create -p ./byfn-network-jatim.json -u alice -n evote-network -c alice/admin-pub.pem -k alice/admin-priv.pem
# composer card import -f alice@evote-network.card
#
# # create card for bob, as business network admin
# composer card create -p ./byfn-network-jabar.json -u bob -n evote-network -c bob/admin-pub.pem -k bob/admin-priv.pem
# composer card import -f bob@evote-network.card
