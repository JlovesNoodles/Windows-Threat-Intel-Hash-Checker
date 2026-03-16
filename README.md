Hi, This is a automation bash script to check malware hashesh agains Microsoft Threat Intel.

Pre Requisite:
1. Create a application under Entra to obtain the neccessary information (eg client secret, app id etc.)
2. Must have valid API permission (Windows.Defender.ATP > File.Read.All, Ti.ReadWrite.All) (reference https://techcommunity.microsoft.com/discussions/microsoftdefenderatp/microsoft-defender-atp-and-malware-information-sharing-platform-integration/576648#M100)

git clone https://github.com/JlovesNoodles/Windows-Threat-Intel-Hash-Checker.git

cd Windows-Threat-Intel-Hash-Checker/

chmod +x hashchecker.sh

./hashchecker.sh hashes.txt

Sample Result:
========================================
Hash #1: 44d88612fea8a8f36de82e1278abb02f
========================================
Checking hash: 44d88612fea8a8f36de82e1278abb02f
STATUS: 404 NOT FOUND
ACTION: KEEP
 
========================================
Hash #2: 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f
========================================
Checking hash: 275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f
STATUS: 200 FOUND
DETERMINATION: Malware
ACTION: DELETE
 
========================================
Hash #3: 3395856ce81f2b7382dee72602f798b642f14140
========================================
Checking hash: 3395856ce81f2b7382dee72602f798b642f14140
STATUS: 200 FOUND
DETERMINATION: Malware
ACTION: DELETE
 
========================================
Hash #4: 5b2c6e6b8a9d1f3e4c7a8b9d0e1f2a3b4c5d6e7f
========================================
Checking hash: 5b2c6e6b8a9d1f3e4c7a8b9d0e1f2a3b4c5d6e7f
STATUS: 404 NOT FOUND
ACTION: KEEP
