ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.0
docker tag hyperledger/composer-playground:0.17.0 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� O�WZ �<KlIv�lv��A�'3�X��R��dw�'ѣ�4?�h��HQ�eǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�l6)ʒmY��,�f���{�^�_}�US9�vL1������˃�mz�t�K�Sx(�L��&�"��%)�.	IQLg�3�x!#f��N��[<Ǖm�.��|�9'Ý��-��v4�ȡ��u�s�}�)��qB�N�9x&����3�.���Q��m��,l�Xmc;1l��L�uJ�b��"�����9�=�>��*nɞ�2@�w�m����8{>,��e�M,-�ikJLŇ12���s�Al<�M�h�P��,�JH�P��9�R�r��2�D �
��;�s�A�?}��'2���L����gS���_D��(�ԌDSv:�cz��Qt�RT��j6���4/m��mml��G��gQt3��]CVO��Ğn�*�A_8n�X�/�nް�H3`Bt�b��[Z�t�Ϣ�8`�Մ��i9~S��w�l�fϐt�H��W��ؿ���Ŕȧ�Y�E3����nE-�P\H
�ۑ]t��5ʆ�l�51Tbd{���QR�pA'�5�7���),/�P�
!�A�'79������?ZF�(z|��4 ��J�D�u�Gp'p�N�k�(
�0<]'�"�@�������q�r��x"�:��Y��]D�X��}F���K�f���À"��2�1�C<.��g��ǰF81���64���ؑ0s�0]�&��F�>b�Ց����7gX���'4�4�HH�>�8|2�B�%��[�P�G�K������]5�q�v@P���J.G7u,;9XǊ�zM� Ӣ��)�r��Y�A�]CT�8�K��/�(!�����32m>�G�A̻L�!�@a�uB�nRs��P�����;#�	� ͝�(k �����cGV8�4�,|��eJ�Zӹ-N��Q����� ����(�����ʋ�)�?��s�q���d���"�L	O��|6;���(,O*�C��V.����,� ����l�6uX�C��j�M��y�M�Ӏ�Ǵ��n4��[{[�zy���9�&�w㣟��]�_\_x~v��Ds��$�+R�^.���[����Q���c Hs�g8ؽ9��u	���:� �'�h��r�oƺ�O�	�J���x0K*���jH��^�\)ml7N�zl�B�p0L���<6����B�����6^���G|l����=z��^�Z�1z�+�[��jU!���u�؎�O��whV�җ�䔁N
t�k�I�{8��N":� �"��>���l���d� �}�4΅=�K�x�'���YH �)��S�3��P���E�{��P��2Do�v�����q>.�Z�̨��5�C�@[�Ј�ғ�i�P��4�����p��"˳��Oز�C�%����i���]#�j�Rgu��+�۬ʳuR�q]��%���q��&�R���;q��?��d��6Xh �Ɵ�)�.��l:8&�y�t�=�Vh{�X
r��M�@�Ț1�qLݣ{�����F�mz���d[�h�ء�t�b䧥�ř�&H��hP �"���bC�p'�$�~��/Ņ!7�6�>�X�O��6���-K-�>�Z}����Q�Y�9��ot��f��"�l��v�����u���/a������Ŕ����e��+6��{c[R��Q�l������d�͐���,�_L����]N���Bw�6ɒ�U<�i�/f��/��)�o��Vݿ�n4J94U��.��-+Ц��mv�!�q!�6����"4s2�U���Ć���x���Y>������r���#.�U��4��Ͽ��b*%�����l�/��y�_ᭀS�f^���
�49'��l�1e��o�Úji��"lۦ}Y�f����nW6T'Α#��mGn�7�Sn���F��%�����T���ѹ��c�6�U�ܰ"��o��ǴY���`d�&܄l��l�4	uM�^��]K���(;�~�q����=�n{������Z�G���xr<������)���sss�X��M�8�V��Y��l,�c,Z��I_�##C �u��������F�4�on��ۜ�s:Z������̢�ϸ����ۖ�Q��_!F��=8�/b�\^��K�ɳ1'�k˟{4�u?M�>v'�"�ō�z���R�WZ���z	u��V�0y�տ��iO"*��?�@�}3e��&�(/�ų@��{�v����*�i�;����A=�Nps^�����6�ݎ��{�]�	%v=�S��cl����7U�!��	�.`�0L��n���(֓�h��Ԭ#�9�;�cY�0����Y69��Cx	�b&xX��"%���iŔ�e�a/��v���b�������؇��}��]S3Nb	�D|l��6꥽��Aek��Q])�nJ���cLt++#��tE��$%=�`�	�������P��mѿ�æ��^�eSM���s+����i0�7��r���n��v���������Y�w�U�y�O$��X��$amz�B�ܦ�I���R�=�^

|�Ez�]����9�h��	q!ΓP5�;��"�T/�/�яb/E����ڜ��M+⬼�rf���/N��?#�/���������a�g�B����
|&�����H�$���l��B
,�Lk`k펋��
�e[q$A���:�1�5�͓`�Y|��n���*�t��A0B�� ��b1n��������CE���4�`���2}o�bp��Ԅ%/]{���d5U��¾JQ��dR��e<\������enS'd�{\���G�Pp�x���Ul`G����_��?����o)��!9c v[6�#�m��5�1{`�Z X�v5�;�e���8�S(T��ذl���Dn
� L�,]S(�)�	���x��ץ�[�~	 7�G��}�}-@�-T���(��(�H���j���f�i�N���ۘvR����f���7���P�	1S9�S���M6Peky�q"�9�1G��"�cz��1��s���Ө���W�s�>��;����"[T&P�m�	����)&1�|�	�K8O�/s�J��6?&��g�h+������X$h�i��O�~�,�\[�H\Y�S�D������r1@@a�gQ�	��/�ܣ�����	���N���"w �k�P�8)Cbb+̐����EL��5w@g-�'8�%�	�UE�d=��&`��*�R�M��q��M'�//=�mal���pǥ>m��l�'��.w
d(�&w9&<�|�ilt��l"U����"l�#L�=�6�Ւ6jÃf�m���?������@ f�P�=z���:�k�2��f����ae(���c�bh�t��	�gb[e��k�8�B��Q|�鱆J�&FL. x�}�G��̺�6E6.0�i1�@:��3J�^O�a�R�ȃ��
�5X`��=����+����a�-��ʚNɛgO �$on�Q�+=�[r��$�hK�jc��!K��x>1d7/�����M�e��]�#��T/M��oOя�&�K�P,�Ǿ�a�g���ĳ� B�,�� Ql�2�
�� 9�1Q�>����f�w����� Z�]
�Y�{��侏�G&�ajR��D�)���!3Y��m(��i��m4��@�뱭�:K�8b,>rq>	��^ZD�|��M�}ـi�=+h8w��4�F������!�F��S$Y#�F�7�d�m�m$�`�#����Y'v�Q���	���9T�)j���4�!cd��rB����m��f��u�;��iM�iA���K��%~Iy�P��FC����i�����HL$��>��1��ԇ9���[�o�g���'�@(�]L(�C��b�Ax���M[������~Q�?/��w������ϧ����_:����]H���n�{|坫�^��?��Ͽ�Չ� ��M^I�ĥŖ"(BjIn5[)eqi)�j.�)1+㔀S��Rs)�R��RziIhf�bs1����;�O��&G��or��0�E�p�D�2�KW8n���0��\����տ����q$_\�ry�'�ޥ�'�ȯ\�V���]2{��܇�(�7"�@sAE�����_1����=�oz�Yy��}:�/�<��������g�����)\�*J�~���_.���u�~������y��ꑿ��~�_�������
ܗ�{7�]�����+~F}�{�؝^��ԏ?Ke��I˼�J��L)>��6դ��3��ߑN)Kb�UA�-yqIT�� �"r5��w~�u��O��O�_.��˿��6�J����"�s?�#��G��C���t�o?����i��"���~�����>����f��ߏ|�~�_���o�D���)��j��
�z��R.H���*�r��_(H�ۖz��.׊w�����[�~wi����^�(����'�����Z�(��*5��j�ŝZm�Ի��}TjT��$l�
��zM\q���n��m��W�5ږ�W���W.=p������~����WX�N��L�5*[i����j_�׭6%��7)�ԯ4vŒ�M��J��W�$���ۯ��ҕ��2�X]-��*k�~�H��oWw��nC�w�z�WbC+�zVq�~�z�]4�z�R���H�m��0�T�n��4�UK����Ao�G�K�<�_����v���궷+.��z��ڦ0E�ԯ��n����J�ݵu�a�h�/H�ݲ�\�jJ�֖J�AM2������s�|�~w����t�N�a��5��Zκp�V;����;:v��������[M�s��R=����j};��\mUV�^��Y�7��Z"/�ܷW�i�̂z�S�vW��
�C�{����{R��OI�Z-U*�k�U�՟d�R{MtK^Cz"?�r�{3�9����{��A�c=I�
�`�%��bP֥r�0������ߕK�������-��vƾնRGU��G���v���@W�����ֶ[�V�E��jf}��^/[�Q�j��⎳��i�������S�i�X�RZS]�z�N��@M�W惬f����z�Q�W���t*���J�t$ՙZ���j���wA�=�~���/m�6�Q܁6-��)���hW\�6������(����h4�xggG̮f�m&#�CA����b����nV����\M�s)�m.s����( �$�U��U��ݶ��<-uQ�.0���s�y�s}��Dz���~w8��l�׉����*�X��(���C�>��ĸ:tT�pbu$��!�CB�����|<�#�N��� ��<���;}���ld�s�g���*"�[���ӌ/�w�8�,1��.׶����n(�y}C�ݠW3GDD�C�l2[���f����^Ϫ1��5Ѓ�P�>�_�|Y�))T��ǅ��ǵ�a�u��E(�|�ŏ��m�>�(W����W��(\xՃ�X+\����o�)Vbihժ���t���#Y��
�*��2Q�-k�0��m��c`�Q�6'i�4�i=/[{�0��p�/R�D���l�z�J���D��OUy7�W����X���u;J�i����ij3P�-�t�k��ʠ�/��	R��G;��'a�x
;¦k -��RU����v�a�$��~��9�{(�=�z��R�=;�@I�y^�)���@I��}خ>/�@���z�&���-���ؖE��>�bQ@�M��v�ME��f��JWf�%�D╶��[�d@7�+�/���x�����]�՟3^�ch� �-��}����ڰ��>Fj �16Ԗ�[�O��np��@k�B�.2�	��!���ʬg�t�#�H.#Ę��n�b6�D��QW�N@�����iB��-o�y�tS&����d�J'�����<X��
�
_~~��׿H�ۍ�;] �:��_q�O������f��U����6��+�}᫃�|u|ﯿ+ݜW��I(����=��_��Pxux/_>?��/���o�%���P៿+��!�v���߿~�7��߿-�뷅���|r�?����@e�6�KQy�0m��N�V�x�E̷��+<�c>����N\�&^����_1�լ�瑹���s悮�K������.w�}d�FB��
J$�i0�;7�Bbo�²��1���^��=R�Rk�#�"�h����d77�=E����^�L�f?��ᦶ�1��}�	˞��N+�H�3G�1�5��5˔�b�UX�zGF��3f���<fx�y�X�IȴZR�������X��ӀeJ~��=��u�Y�|y`���U���d��x�Ԡ�J_�2<+0t�ݸ�m����n�����AA�0a��p:n�t!�b7&8�x)ٙ;�'n����Mi$�%GR&zi�����!=��?=�i�D(�'����$�����ׅr���ak�<��V:���]�\�3��@����S�b�.o���v�Hة�x�N�c��1�t,���C�����]i�ӻy{�W��d��O�й����~4����4��oM��&�Cc�v��6��Z/�f������yb[u7�ǭi�F�j�IMfV�Ѹ�WR�-UU�{B��(L|-��k��)׮;ˈ�X�3�9�*��ך��W�ۍ?��E�.kO�8>������9QV.B�~��-M2���9�r��W��c�=X�Nmd��<)�Z˾"T���q�0>o�e�*zc�H�x�lG�N��#0jp1/�{�契���>�I ��E�L�ŬPk���`haʅ*�m>�@2�E�&�l+G�8��;���U0��;s&Э~0�X;v&�D�
t�y(�<ôvǩq�bHN�� 5��Ĝ
�J��B�B�3��钏
���@�	C�=�D�QQ�I�=�El�/�7T�WIDyn@��垀B��=c�Ym9�ǖ���Y���TՈ��E�����T�;�{
(,:�z�E|\&4{�F�A�d�����&��B�%\d���%���m^[S;VXri{�/�x|�3�}Ǥ�?iu��.�nu�?~Ѐ��t�ׅ�Υ��"���~v+��|�I�5��m�a�
�&��«㉯��e2����u�,�)|S��"YDs:��/NKN
�)���͏?������?��{��5/��_@���3;���M�0:�$\�!��,�g���:}N}S��d�*f��h8M�=tC���������Ⱥ�@�V���{���t�}s�8��H����ۖ!�Ջd򩼂>���>x���O��>�5���u��C���J����������#��W*�(������?����S��қҟ��_f.�x����j�;?�d����B�#L��W�#��������<z�Ǟ������Z5Y�&�[�F�?���d�'����
���$��O)��u��;� { ���=�����*Ȍ��:�Y�< �����?
�����4�)�;��>�# ������?F�񟌐�w���&H�Y�9ɐ����?P��I������ �m�����.iY���\�?��8�i S��� d
��_�������� 㿩 '��<H���0r��	� � �Eg�g�3F.��\��4����&!X�-����/��c�������W�*�ԑ�w������O�����m=��V�=�� ���̐�������g	��_���������`@6ȅ��������0��r��S@�e�L���݅�|�������/��!��A�ߔ��wHA\�.S�rh�ȁ�Ѩ�;�5�2�T�E�t<Ϧ��3���3H�$�~��<�?F^�������%u�����;������f���V26�i>I�.��0��w׃V���Ƣ�R�ţ[[t�h7n�b��jC�yEwr�]D��]K}��6p�3�T��8�)�-Kf�	a+���+BD"3V�ϰ�l�\0~��vR�a�c�_���߻���?�!�������h&}s�<����C��������+�9���?��<�?���C�?��T\WZM�,uY��Z1�weƪ�Oz�ZG�����G�W:��@m����-xY�N��1%��:�F��L�re�\SjsJ˚��[!F�H�#ٜYt,��R��}����T�"��8�����z�>�O��\���_����/������Y�� �r���B�0�i����W��q����*�П[-��	D��)�������o�g+l_D��������6�|���%�U�-S#`�h��h�V��iٝAÞu�T�E�f���fqI��7�����>H��Н6k��B���,0K��|9�mWMB��l�]*~�ή��'MY��<3��rz[�n&��B���*M!֮&��3WZиN"���[A�+��3��D�w.��3�'4_�	a�{5X�f��NE�x4jz5t��)�c���l{�H� �R��0^1����@W�m���මޒd�pD�jT��R?y�w�<�?�g�������k��F�?6�߷��?�@.�����A��T�
��"�����Y�?
߳�+�?�����k������`�7��_���`�W��k������
��K	��?��Kn����y����
��������/���߳��@��O`�?X��������������%� ��e�<�?���!m�������������
��/`�����E�B�����G��7' �O���������
r�����_X��
�����s� &d�������g������P"k ���9����̐=��̐,�����_��������?H�i�������O� � �@�P�![�O�/��RA��/|������/�O�����'���0��O�
�L���O�?������VF���rGV}C�?)�_�?���c�?��P7δ5q���1M���SHy.+�f����ke���I�e��Z4tE�z*:���a	��ͼ��;���
��P���bd�Xr�3�%��!ߞ%I �%I 倴b&n�Y����`4Db6|4]����`IuB�8���f�n`��8�%Bz��z[�F.�ƒ�#�4�CԵI�h{]DSc{8{1v�����ܳ���H��?P2K ����_.��������r���8d�ȅ����#�* �A�GP����l�(�%����/��f���␩#���gP���_.r��迌�����0��\��� ��/[���1��#��O9���)��(�#-Ǣ˖;�`��&q!PE�2����{�6E�t�B$���c}�?a��1������tp���-�s�E�ׄ����U��UDv�u���w�8���V26�i�A�)=�ge���/�=�ὁ�2����o5do\q{]��d���w�.Z�m���XY�*��ž�Z���Ǆ>fY�f3��}9@��}�)G�V��Z��]��V9��]iQ���]�T�xΐ���f�l�4���"������?2C����o60���%"��_v���oa�'�pT���̖0ėƸe�Xu������Z��`� ҖG�G�܎X��%�X,x�V_��I���z�$�E�Ӆх�eWQ�4ة�����5D��g�*5'�p��Ɠ��ng8
��S���Q�����@��߱�8�O��Y �@�Wf �_ ����/0��_��?@f�<�?�������?3�>w���CgA��M�+�ExdF�%<�X����75 ?��{^@�p�P��ښd��,��Ԣ({q���ڲ���vh9�'�0g�/Sю$���N��\��ޞ��5g�v)����NF;��T�A��c-&�j7:���W��XVkW�8EFk�?{�֜(���{��U#��Ůڀ��"�r��3**��;==�{:�t>��z�j�ې�#�/�]�:��Ҕ_��5$�L^����56<���n��]�'���Ծ�,�Z^b��'ے|�S�s�K��ǝe4c�HOt����Ƌ؋�I�PY���k�F27R/��z�vHW</3�l�N��z�;v�-3��("aߝ�G�;*ƈ�LCC�A�Nh��&��?]������_g��u��	�A������?���/������X��������/���_ ����?�%,�8��$y;���.I�0d"��~$�1O0d@���(h��<�����A���_Y�����F%��ک�`'A�$K�q��b���^���+G��[���[nQ�Ѱ���J�����?�q��G�����Lwh�+(�����$�A�I�U�/�S��(@��\x��APAȥ<A���R\_��HHq��I6M#���4�����OB�<"b���D��Q��	�����,5���p��ǻ�(�o��!�B���iLN})���^�+�X��}�\�V����������U����٫��z�������������/�����_�T�7�K��=ޟ���GC����绌�K���?E������+����@���Pܾj�?(�����00�	u�0�	��#���w���J���^����$T���0U�_������UF�?
�뿫~/�"������?�*����:�����P&�ɠ�����H����0$���g�_��,����k�ꄽ)ϻ���#h	S��Rj��̙KsP��|/�R��3r/�c^�ѭ�I�Lc@����ъ�L�3���V�dZ.�>��&3��<�(�)E�O������!�*2����ʹPa�/|{fj��a0��~s�[���[�I�������fEb�驖��/�E>��-$�N��X�bt��*�n��n�P|f_:�ɦ0��ޚ�nk�,��^l�:����^�m�8$��1Qm��^�L+5�x�ʞj����.I�Ue�+S�J�:���'*&�o��Ŝ��n)�D^�ͽ��V�l���~��
%�Ƚrp�m�]a~�)�9��8?w'�E:�l�U�-��%mQ���n�\��4	���c'�_2�Ƭ벻F���"�Z���=d�����˰���{[T׼x܄��;�;C�$��R����VV�����o��CB�b��!P���v�W�g������P/�|$>�:��d_�?��D����z�����Co=��)��|��re�����.���Ku��s���
g���A�!����ܯ1���Xw���R�F��D�5�I��񞣓�����k��k�7��[.㣩�9��C*#5%���(K�j���ǈ�3���]���뢤x�$uq:�(�9k<�ޜٳ�)��NG��݅7▶�NC4�A<����9S�xk���m֧������q��)�*�Ԯu��p��Z��g��sQ4o�����`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`���멩�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-���]o���/ ���C��4  � ��k����A��"�f��	 d���3���������a�v���~���a��B����K[^�_�������i�O�w��݊ �I �4F�|� {���5 ���E�>���i��: �`<M/}���m����Dv>aQ��{����c[�O#q�i�;�l��3Og�о].c�?�d�)� e��� ��B���p~.�Yh<�W���q�,������$".�ْ����}��ڑzvP��+�ɘ�WHn�l�'^&�������uq���ckii2QԞ1�����vQ����4�WG�])�K����ʨC��>����������2j��P ��:�8��8���8��W[�D-�?�A�'	�
��-�s��w	������_��"����Z�?A\��O86L��)�Oy!I#:�#�&��"��<�h<
�����@h��`Kܻ���?����r���e�+��)�!��=q��qb��ry\�[It����<|��f�r1p-{c��K;���eD��e���G�<��3�^&�;�Hu��So�����	Db���ݖ���*��inʰ�������?�����~	��UR��?��ꨅ����ʨ��߿�WX�����������_���e2�ƾ�����`�F7Mdmޏ/�z��6�?���FY����,���pi]�t�ᐻ�T�g�Ck���8f6��%'��ַMwr��^���I������(r�LJ�2�Ck����
c��{+�x�S����:<����h�;����P��_��_���_�����*��@X���p�a����g�_�i���=��:���=yǮ��A1?�R6����_�����=���v-ɗ|�؄��q ���Ԧ��'j6Zǅ�e�6ل�4�­7ӵ"��q$�n汸]Оٙ1g����)UX�y���}��X���%�:��o��m��ӭ�o���-��t����2�-]�t�\4��6��@ԚY�O,�8�Z!O\��N"]V���5�Q�^aѮQ�n�DSȺƝBw+���$��8�f|���q��Nݓ���v�!�$����A�q�X�� �y���L#9l�E3]on;����+P���� ��_E x�Ê�������P�AC�j���+���?D ���ZS@�A�����A�+���pך�J�߻�����H����������j����O8�G��V����_;�����$	��^�a�K����P�OC�?����������C�����x�)���v�W��_��V�ԉ:��G�_h������_`�˿���#���������( �_[P�����kH�u�0���G�����J��[�O��$@�?��C�?��W�1��`�+"����,�a��<��AL�	���B��<�'TƷq�E�1/$4�$��ﳨ�������O$���~/<,.��e&���3��H�O-����vD_Xˤ��|��0�[�x�)��px��f��U?l5��(ml����f�*w�N*�Ao�G,.��R򕔵�麤��v�@�mg�éU�?��:<��G���(@��OpPOP�����i��(����ă��p��d�m����{���A��A���A�_����*Y���Bp��i��x��1q���0��(��H�x"JX�S*��
9�OB<N�"8������!�C�����ic<[�g�|�6�k��t��LO�Y�У��"�FG�y�����fs˦�+.U�ɑY�TBv�K��s��xw6'&i`{*�LN�B6v��d��F�n�����q���t�\� ��V�����u ���%��_SP����)�����O���4�?
��������?<*���z�����/H�Z�a9d�����W����������:@�A�+��U��u��E*���G����� �`�����?����P����e��"������ϰ���?"�^���"H|u����?00�	?���\��g��s"�c9ً)K�`9�n�����]�j������Y���l����c?�����n��2	ɓ./�奙m��`k��!FL�w�.�au#�+�h�tW���$����[�cS�7�v�����f-�T�'{����'�)�O�^�MQ,����K��s�/6{��o������T4��]H̠�9�;�\'�<YO�s��$������*>gb�9Qly8MZ�F���ɾ0j�%�*b]��>#�#s��&��������^x����:�?,����r�����_-��y�����H���Ô(����?��D���Q �`����O��!��*��a9x�oǗ��׎�j����+�f�/�~�_��Ȩ������������?����-Z��zd5�qSR������b9x����t1S\�=�ԔG#�\D�n�3G^X�P]����xʩ=���"�5�~l&�X�j_���2!���������ٿ(<��c����<$����5�����^Xj��2����:i::�stһ�6z~��Rx�e|4��=�2~He���(Ko����c��Y
���n���뢤x�$uq:�(�9k<�ޜٳ�)��NG��݅7▶�NC4�A<����9S�xk���m֧������q��)�*v���Y���jYK4���mJb�+�\M�x��z9X��!��j�N�%���Ei����0������r�5gd��� 8�b��Ǻ�:Y�3�T\Y�taXLV�m�L�.�	���op-�I�k�-G�Q������WV���\��^�wb㑩�|v�i�;Ɩk�p������?"���"9�|���G�����A�)���G��H����iHpQ�q��D��LH��B��	�!E|Q,�\DRa�S1�@�x�Î�wS�8��?~��������i&��f�i�X��qwN��(4�c����x����m��������=�{9�?���M�M�1��x�r�&�� ������[@�M7�L�~����M7��I|��(��t��R�TU��Q�����[�v/��'����M�GG�σ����M��X1���Ȕ������~U�T�O��攙jw������h�Ԩz����iz��6��ӥ���}�����9��[���ҳ����O������|jj�������ӥ������Վ{R}36>���vĽh�r��~���Ԫ*���ŕ��f��z�_�4�kT?��̈́�����{�?��;����A�7ikJ�|s�M^��������������>)��7����$7������b�$��t/v��ߦ�y��������0�+4�X��� =��_��_O���������������?[����6��ga�������������_����f�����sT.R�?�Oo*��V���p�_�z���_��w���h���?r �3�@$h�.� ��r�AW��K-�^X{��~�3���b�ͩcfN��F�:y}a�"�7���ɻI��иj�+���W%��_o}8͟|*V�7���;ڭX���Xoﭫ��c���$ҿx�ľ�ؗ]�8���e�����49+�?`��������iZ<N��MV?(U�{�������#���^�S#�n�����}V�����JoʇFI��T�,�t9R�$
,�4P�g���Z��I��rG��=�}�U)����两i�{�ک1s�/_>dG�U㴨���~���FgZ�䊺34ώ��/g�&��R=��8��;��+>�@�?���S:�׵�F����tX��w�����(�)�����������IQ�I�l�b�/�x�E�i7+�b�����j*3��1�@�#�X,OB9(�y	�E��,ni�Q#���b���?Ȑ��}��u�a����(�)D����l�`�H�Y!�!sH5�@f���m#�h{�>�m�HS؏6�2ݜ��i�4:s�a�:������#�ش�G���gd��s1���&ſ�ԃ2/?��y���������+q�Ml�pqL���d3�ӑ�)�"d��M4�LMג��<�Z��ℜA�N��D5?�ؔ�Y�À|�ao�4
�6��A�e�)6����ci��U�fySl��%(�LLS��Jy{1'q��j�/�f1�5�����yKl
���W���p�@3����U�_s\p���=`�M�y,Me�z|��u�u�_i�������B�3E�}�{����Û�����@&hlv(�m�Tw��=�rd��>h-u$!��[b1{��6f�4�`�ж��3M�ӆbP�)�B��jQ4Е��C�tK�KCAopm��X���T��+u�-��.�Y�R�Z+�>�r�$����v���-��I�hM�IU�(�^�V*�싋F������2_��4��v�H���R��VO�t'�������7��%bi��.L��!�	�+^��[�x�J�P�y������/�.�>���ɱ\��QT^yc�:��	���F�(��0�鐡�HP*��� E�+�~p3�5���'U��!a�|e�Gآw\/wgDǱ�@;h�`�͇ǑWL]�l�@��	�8"��@R���^ �~�Ld@�5-����-<�p�no��d���s��N�$:!Ź�PE�o6��٘�*��Kd<��0�ݝ�5N����T����X3>�{`����Mq�?�Nf���s����ߣ$q`�y�~� �s�yhIf�Zڐ�A���t���'$�(��Sl��A������bc�	3�c�24lg��a�Ԫ�/�����Y� �%����%��ևj��E ���52-'��E��v�#��ܠ����B^η,&X<��,���%�_o�䮐��5��dj�vs����&�{ɼJ�T�e�$ݧ��r�}�O���X�vU�`��tZ��g�<K�e��5�u	�U�GS_rj�M�� �����Qh��io�h�2�RL+�Rz�l9_I�5�+k܏��J�xT�W[������i�C��@e]���X�ݩ֋�J��n$��������>�v���uEk�KJ�۹�y����xW�~G���ӳv�V9��F�t��ZD/|KB�321�k0�.U�*��9r}sD�A¶�D,��yjq���k���D=��\������#W�XXL!0 A9���~D,�:O!h}���r�_^v�c���}�Ѫ"���G��8�(k�r�2_�R-���~8���+�F��9p���H$�I����\Cq;Ȩ�f�
��yG��e=�[AV`��n�F��7ڝr�~X;��W;��3�݁'O�A�6�hH���� �
A���,v����f6
���mw����[)v��b�z F�2���(_n���+%�'��H��j���������j�+�Ĕp��`U�{�V�r*<F�Ɯt0'�9�U��sU!�d?�~BD��v��;���~��ġ�l�վ��'窹�IA5����\��[y V�9^@Ɯq�EU)]��N�)��&`��:8��2��.��ߊ}�t�o`N��j�wn6:����KfSٹ��l>���}�$tX�-A�bR�ė��G����]�j����#��5�KS��#�#ap���:#�)�݉�l�Az'���=Pe�\&3;7A����%�s�B��2�?R���Ϻ�L��2�����n6�]�y��]�ٮ�l���?������v�g����?�z|�Gu{���r�v�g��sﴱ��0j���8�_��`�6���ɧ�s�_&������^�-�ՌD��<�_��#��i��fY����,�p�uO�����1�RaS�2��ɵX���_.?��Y��;)�e��V�A��iM���;������ѝo0�_��r���_�Q�:J~���&*<!���P��v�[3UdG�ͭa�-�F�Zʈܹ:"��$�C�l�����j\�����;�G�'���w;dKBO�9o�n5��*������ľ�F@�M\ө���0�N��3jl��6��1G�!������nnN����߶�������Q�8�:�ל�>���h�ApM���������:^�'�`l���>���R���Ҹ����l��1RP����/��6�?�^�o�_�20I4�=�/�,��gl�ϓ�O�_х�⾆]�2b ��t��i�c���:�t�:�Z�K%qR�������p=c��;#�����ajC�2
�T�x�� �q��?S�؁��V� Ti���F"Mj��h�]talA�� ׁ�$;/H��$��7�&��/
Ͳ�l����G�����i�V?l����o����$6x�{�^�Z�����Tԫ,6#�1D��F���hu�d6U�?	HȰ����w���#�z�aИ^G@]�(B�b�a<ői�i��v������VL�S�`%1x��!��x7����8O�bW K�:�?�\��끎��c1��	�\��a���P^��O�^�.�ba�j翁���T�2�F{Y�^J��\�����ooȻl�t�&��K2�&��?z1~+�6^�����Rc��b�����@�u&.b蘅i�d]�� ��CI�s��$n�
��wRm�?H���|�����6��7^/�|-�(�ԢoE�M̙��e�xkNG2�u�{&���d�N
W�:�?�"d��^��
��'ˋ:>��z����mA��]��_�Wf�&������ƀ��ݤX���b�n+F�:��:���ӭGA�o�i8�U�H(o�����Żd^�+�='�����xX�v�����{�9c�kC{��㜵���.��
\��:nLj=�]g`Z�������_I�B��8L�p-�h�)�D&�_n��NtEc��y� n�Xj~����*�Y��Jj�	�Wa*>Mg�1Uh]j�;�O�	S8�V0VD �˓��%����M��������RYJ�I��u{I%��I����YO�v���l:�2��ܞJ�J&�Thj/O���<��4���_�����(X�Z�_2�=�1��ߖ=�b��8�4�;	g8J���?�tG�t6�J/-��LߠA�V��$6Z=}��K|hx@�F�αk|	p�Y���g��{��tؙ!zZh#�#��%v)��+���.L��*�&!xfKd����eGV�	YRѝA��َ��-@:^�I�e̐�2��py|�Mz>L6y)E���dk��9��~��˩#�|j_w��=�<�h
�z��u뿩��|��d:�]�y����Bc��Ѥc��<2	�)Y�SƣO��mZ�6�����u�����I&s����z�����c:��J_��<b�?P���v��Qҏ�����l�m�	�nOl��8wDb*vtB���%hN���(HPL3��>̒��6����mG���7�o�f�.��{��[��N��
n���:��%��1A�|[V�6b댍V~��]1^�v�<��n��〈8�'��n����6�נ#9���������>"���dJ@�@'�^�F��G/�Ssw��эs��ƺ�]�G�Y�7��(%�I��֞���_�)�O���dv���%���'mxD���Ǿ�. ��gѾ8t�^�r1ޛ8;��k�;��gו\wڤ��}*�_G٤���X����T����;xlC�? ��|zk�?J���{��F��E���g*�������t*�Ρ���f�[���a�c@�?9��	�+��-F*Z�����t���y�.��"�@a�
!�_�栨MFԂ���M����1M�����=�b�a�}��e�_m���{��]~��K4v�@hc+\�p:z�����e�����\��_`��Ve �K��%H���+�0v,om	i_��<��C1u[��x�<�	F�Ee d����
�N4.���,#cLQ��b��� ��ّ�@��`�92s:�R�|��F�q�)#��q(�9���������*�i\�UWЫ�:���_A�g�j��nBV �`��u�H� ���"���4�A�-J���'�1ʵ�>�=f�9�A�w��:����\ Z���=5��Kg\_�� �*b ���,/�5WM�^��]�'�m��������Yy��C�q-<��Cp-͙�ы��	_	�k�wE�FT/��	Ϫg�j+2�~�Y'��Hq�t�78�1���t�e`Z��<�a_?�F��z���)��@Ae~����e�6� �Ã6�n�kH��#:���<z:�iȈ�3X�� \^�'|���L,��F�`7N�� ~���Yj�yd~���f�j�Sk�g?�v��q���KK�X4��O�>6l*��&״�'Y,����3��afa)��ܟ��D!�I<i��C#�3�R����X����oy��Q<j����kڻ����lB��ED�EU��m�/)�Z'��-Qx_G��!Fy�J�O���e=ӋڎS(%]���p(>����־2���2u{.��P��84.�f�#8#4��r&�cf�6t�� �#f5<|+7z#�yAȓ�����k�qK�ӽ���g�g�ܶ`������L�v|��4�%q'qb�F���8�ǹ9q�Ѡ�!��h-h^о�������V ļ x@+� �vn��tUuUw����Uu|�s���������k�s���k����C^>�u��vk^-o���,�oS�����PM���]<���c�[5ᶼj��>����ڗ���T���ϼ�u񃕗�v��׭n]�m��"�����f�z'.r���ӎ���f���R�'����[-3�^�n���[_�yP[X��	`oM��f��օ2Y������@�}�p�X=��n�n�M#(�Ƃ|@�z���yV�Ѻ�=/Ѳ[,I��2(mÓ�ޗ�,F�}y)V:���^|�o�Ԕ�99�[rl7�@�����o�g>��޾�+������w�wY���I���$� ������A��� ��m�m�����~��/�~�/��Z��1���:RG0Jm֚X=JQD�F�J��h�Q5*��U��)
��Q�Eq����{���C4����<� t ^�l�ïp�������?�q�ޭ�y|����u�����u2�ށ^;���soy��[�K%׸q_~�m�[�˛��:yMm���*X�yw��j}�{䗸��?9��6.Y��"���O��`�����A$��?�����������7���<�����O��������~� ���_9�u��?Zp�+��u��h��!FD�����*i��!��Z#�P�p���S(�����xS�Rh#���Rt���/����W_�I�����?�:�O�>��>��0��&��[����i�߂���y��7�￹"��z��?�/���o����C�t|i�l�ݝE��`Km����:��%k�V4��l3I%4|�V��S��Z�v6'I�f�^�hp����i��V���ԗ'�D�|�5���Lo�[Z����_��b<��iTlW�b[��vUu�f�2iSĄ8e�tr�\�"�fQ��/oM��>W)M��.5�u͖��81zq,�;�����d�����hf"�;N�YTH�Sƽ��4�-b����ʸ�R��w�����~�iW
��c�w*�Ur��6��9Z�s�N�#�Qa�h�3
	�Tr�t�A+���*n;������i	
�7G�fӱlR*��N��XfR@�D��­���LS���ǎwE:�N�-�t%����p΢����8��3�9�_�Ȗ0^�%=����z���L�AT����a�DʽY�bu��� ;�|�˻��ӂ�Ά����m���h�)5�y�H+�0��1vԨs�y*=�Y!^6�
N��RA��t܊ғ~���S�3L	}M����Q!|AJ�߿t6Ž�Tg���g�Y��	�a&>�I��wL�LR��ܗ�������h�n�P�+7I(��0����W�VK8}��g��҄��q45e$$ޙd��KO�L٨�Jm�&�(��$��ҝR�4�J����TLm�*Y�;\4S �����*��⺓j�2�i,���y/�#yc�й+�g�ê:&���0��8���-huA�f�0#DM�	LU�gS���+� ��(%���AM�hXT�Sx�
��j��\+X%�)R������^7��5z��Wy�)r\ 墘ȩ�1c1��42J��(�;�x���Q��?N$��҉R�<�ڈ~R��<Ŵ���Ta3�Z��b�E���S�ԈO���=7=�+�k��ɞ뉞��p ���U�����k�Sn5�9bl��8�G��U�L�6�jIV��9�	=��@;�Z�b9I %��b��U�٠r�!���NOm�q��k��4⇬��f��)V��ɼ�EG&�Ȫt{� u�!N�%�'��4��`Tc>F��pw�#F᜘U)�1�#v2��V��i��pf&�A5>�MB�*�a=p�S��f��N�D��`�m��������I�6t �q�>x���z[i��c��g��ƫ���?o�6:,vZ�vk��Z�3��W]��`��÷ëz�'!��ғ���!������mל�s�i����vQ}�m�_� [I�q��+�����߇~���W�g�RYz�RYC=����d����,Ó�2�h���|U~�2?�х��g����Ė����M�s��h͢+<����5o3XR�������4�EFY3p�#�mx*JI�eF������a�K�Rİ	��#�9&X"��9-֖ E��$ՠ�H&ۅ�Z%2�p�j�Zu�f�5�>��{Z��Q�Y�����n�d��DP���e���je�H�;��Wx�w��s�� #��&�"�x�.˨5~�5:��Ҍ��b�$m5��4�q�X��*�B�3�S����3	�cxڠ��6����"��n����V&�N9�j:���Ҩ�Q�:p�]�e�><��&n1���L-T�X��Nb� ���p&���E��ѯ_:iXOQ�me���ҕ�q:�G�ّ>n��g����Ed���O�V�cs��V��n����`3����|D�*�L��e��,c��2aY�mʜb�O��;��|_Ow����te�=W��uj%s,ů&���	9OF��=2J��=�U3�Ρ��Hg�UN����I�C��!)}�4�u80��fW�|�J!�q5��mE��	W34Q�2��#�5Z�����/eV�i'��,m���G��T�{���=��Nt�9��� ��tb](����Ɠ�Q]p/���-��T��i�jQK&JYi��d��$i
NWTE>1��ew�蜌E�x��&�'�fݚ96_�ZH'	#0*�ދ&�ҷ�J'��K�DF���X���IW�[e��Ť-5"��J��[A�s��J�Lck���]���B���.���	8փ/&�k���I�S��lۼ��BҊHJ��b��ar<��)���!�;}����T�����<$�դ�B%�;�dSQz�V<bΣ����Г(�(`-Q�(���ȃH����Q5$?�ION�		�5tZ熠�bbB>ż� ��Q�2��%q�6#x�X��2].S�=��Dq�B���JXe�´��n�bjKs�ʇ9̜��j�D����/�L�4r����5W<��K_�^�V�6'�����D�U�+��с�_�ymd���x�+����j�h<�6�@��;�eoͦ���f�	�&������c�Ǐl�|����zz�F�=;��YȊ�i4�>��x���M��+�yN���eX:m�^��V�S���27��>���>8�VW'��x�E������������f$��;Oچ�D[ė�r ^Z�p<��o�5FO��U��:��?�V����9���PWi���r�O|�E����;�G���G�=zoq�8��ѰgzQ	�pj��ͦa�x�G�Q�r���vق���ң>:�"�i�͘=s��4��ۄ���Gۑ݋_`E<�n�r�pC;�uS/�#�n�G�M�P���:��'yCO�{7tE=�n�zd���Ⱥ�7�u�;��Ds�u���??��Yzڰ.��s}l��B֟�	#$vB������SN`���^��d֗��k���r���q��[�Ҏ�����(A���". ���l�I9�I�_Y�W�V��ΐ�q�*ǒⴤ��#DK�}5׍��l�;�V��q1��Z��+��T*ݙۖݵ蜃�G�3��D��eA�h�[ߺ{��u�g~?��nj�-�a_��%�ߝ��)�ǉ���	��z�V�`���7��0�a��g�?"��v�쿡1�����9��������2�˶(���A_��0q�Q=�P�t�t�I��0etj�]P��E����L�d�3�i�y>%Y���,M�v$)�|_T:�ʒ�y�f/T��� +v����gx��p��@�ζJ����,��j�s�x��2�u5Fl�Dv�|<sc~?���5��vD�+�q5�/�������Á�w������tO=��������c���ym\u����������F�?����2e��w�I���?=�c����'���������)sN��G���������/���^:5��=@������(|����~�]�6�C~"����}���9���?;�>�]ݎ5�W����I���9v����'�3���w� l_�/��4a�����{����������O��	� ��������������N���x��#��#g�?���ȃ�/tr�'�����O�8���.��g��`����[����г�?��.�'���5��{��O������ ȶd[
�-]'ے�3��`/�����~��W���"��_l�o/�?��}Þ���'����}C���������^�0�>�O����Fvo�ֿ��[���� g���d�k'���(�hp-J6p�KB�Z�B5��T�H�42�!u��7�5Ju���S0!`���y���{��G������npA���N�B�F̥��f2[�X�P�l?���ʡ��u{gEv��E�f6���dE	�!f�DG᪮N�R��5�<	y5�L�&����m��xՊ����O�Q�9RY���\?i<9�ˋn��>�� ���K��f������?������~��������Sxq�����Y����h|���R����!S!��kÒ��u��eɱk��Jam���b'��d�N�V��� ��"e��#�1p�cT���hl2��D���J#�21�=��Ơ�,Yj�ćz8͎�y(���U��?���?�]}��]Yw�J�������G���>� ���b�rG���((��4��9��dg��������f֜Us���E��@D��
�A��A�����+h�4`� B�	���@�������_��k9q��&i�A��ԟ��֕�/�����?�D]�jc�I���Jj�כm���6��T��t�@�B�;�N�i�� �?i��aI�5�8(�|P�J)M�si�(I�1��v�Fvk/�$ᐋ���6���`4澮mm�Tg�q�뭬R]�<h��g<ަx��FUs��L!i��ծ�]W�`ﱈ��/�oG=~�m�uu���{)���Ϻh��:3TF=���v�f���!RX$���4<�V�H͛GmrəQ���|*�i�S/�Krg][��r�����(�y+0iԪ��q���{����k���翜�x@��g�;����8����#� ��/��Y�f�� I��8�����#y������I������a�#�,���7�a�&�X�a�� ����	��27�!��	���<"��M����!������/�!����g��0�\��������_0�?�y D�������0��?�����#�����������
����������>�������c6�����?�	����h�g�;���?������/�7�?������p��ʐB��_8��7�?!��	��?��\����<�@�O,�����?@��b��M�/��P��Kg1Ԇ���[���������3`�A�������?�����~��x1���l�i��fkS�ם�g�/������<7����!Xu���z.S����5 �!�V��iǷ��N����,J�z}�IZ]�B#�]�}��i����Ff��?J;S��O�lP=�81om+�`�Xt�/���Z�oj@�k�?Հtr5�\���,M#Q]�Rz6�LCS\ש�V�liZM���9Њ�V,MH��cv�z-����՞�i���/�%?2������������3��?��p��!���������O�aI��!��g�;���#�������?�B�4�,�����#�������C���������������p0�� ���)�6��! ����	��1w�?r��8@��
/���HDRdN8�g#��E�g6bYZVB�	"It	A�Kb��;��O?����A�s����<x�����E��0F��߬���ښmj��ٵy��Y�<}�5ͤst�pݸ'���_�~s4N�3�7�s�q3�w��p�iգE5eJi�Q��սS����!.��<v�sy���%e.+�&1��s8L��Y�����k׳��4ΓA�<·F�TqS�����͆?��͋*�����Y
]��%���Ł�����p���]l`ї�[���W>��%��r0�W��Y�����暳�:ͬ�h�,s���O�VN���m�$It��ܯ�e��3��@����5����_c{���Y��\s��ìe����N��ܤ�i�/�hx\�,��_��M�A�a�ǁ��� ����3@D��
�A��A�����+r�4`1 A�	�� ���W�W~��4H���Ў�l��2oK�ob���{������z Rυ /� J�8ݣ�!f[��Re&%�z��N���#?XL�a_q��|R�E��cY�N���z�ת�/:������y\r�-m9�h���eu�yR�����j5򑦹^Mͯ{����^U����~�Խ��������{�D��u��uٰ*~�H����CU̽��9U��V���wy�,���2�	�#���k�z�z58@c�L��t��I̠"���z���u�SO�x|r�^�ɭ�uh6)�"�E(Ys*���h����o�Ʊ;�F|��F
��	���� ����翜�Hp��$�F���i������Ӌ`��o������DQ��0����/���_@�}��/ 1��P�e��"�e�'��x�H��0�}1HF2}�Jp��X�2��FV8(��D��o�������|d��ZW�ɄvU@�c�Gc.�#�Iw���Cu�b%�͞��]�\U�����
�����_X����������������a�H�V���i����_�x0�H���#%�]��@�h��Y1���q�/B@�� ��	X��	������,�H���q�����j���OS�x������a��m��&�t��O��6��2�L�N\��V��� b����*x���E*p�����hX�q 꿠�꿾o�׿��$|M�w~����F���|����b�oE^�s�9�����>H��p����>���^hѯp8��o���.��1��gi�v���c.���wG
�?������aB��� S�%�� ��/����Wa ���8���K�-��_8�7�?���@���_���g��c�G�u��������_�RQ��s����~k*�^)[֕Z(�s/��Wɜ�v��4�*�a)���}�l���/�f�*��p�j��C��Q�ؚ��;ڎ�V��1>Q��0GCg����<�]������:D���9Dջ���O��e���`~'F�l�[���)v�.�?8��|�+�2�Y��O|�,�^�Hj᲌8�ty�HKֹQ?i�Is;-7˩1���%i�9g����d�.�L����S+-|jz�V�C�����x���9�]�s=~�~���.M���̕��������Ȥ����9(�{|�����g5y�������VJ���fƾ�n�vE��B>�������Ss�^D�d˿N�ˏ�V\9���7ϴ2b;����ΥY�w�8�+�$�G�FsW,s�<AD�A��:����C⋽�1[�V�ʍl��v�_-F���7����� ����5� ���[�����?��������`�A��������������/�?8�ֺ�N��f�6Ci�1K���+8t���S���_�����7J�Y�X�U���g�Δj��>1�M���3�X�gѭ��������sͿ�e��V����b+#�5�q�"�������ߩ���?U߫��j�^n5�1�n��o���F��\�D}J:��V[7����x�5�FM���`Kci���t%+�'�8捓�y��5m�7��r��Y�{[�u�~��U���}��py�����P-m����Y�B�:�E�Xm�U7,�j��JU�gl]���mu��e=�ѱj^�r+|�pE�b�[�7
y�a����qI�-!�^�W�I9���7+�~�l�#A��ۊ��Rþ]k#zv���t�8^G���]�"�s����� ��� 6 ����������/�������Ol �	�_`��C�7,x��w�������q�����ό�8cz٩�O���l!��?���\��P���� P�`j��� P���z@~�H=��?��yw�z�ѹ-��tǔ�{�Ҙq�l&�=/������Q5v1�'l��ú:�R�l`�|�C���/'J{�c�M�oP$���9 �9��4ިQ��*<�(�3��y�b�%_k!u~Ι@�Xb�M��M��9��Z;�J���FUCf����R����z4���I಺������zЗNm����j�g�7�Z��MM�HG�"�*��,����y@���_���%��� ����D�?���@�C  7H��p�_�����������
D�?�N�����ExJ��.�_ ��o�G�s������cI��01�ӡ$�H2Gˑ��Q��r��,r� �DO��%������x^�`J��A�ߛ��>r�M[y��56��2[�"5n�}��C�,��eU�s���������PI]��$��8WQE*�����ܔ�0����;��$T����k�9�+����l���(P˺�?5�Z�W�fO7v��*HX���gq(x�ϖp�[(HX���"�������u��E_�o��_q�H��8[8��V/��֍��J�(����ɹc^��ʴ��IM�5z��p�u�ݥs.�R�����d���n4�Ҕ�O��G�X��eo���]�<OG��T�����[��Ü��^߮���!8��~d��,���� ����@B�꿊�A��A�����+v�4` B�]��������|���Z����O�o�\ePى���M�Y��������ߣ��J;]kc�I��}H�J�.iz�E��%��P�"߭�?�kOMt;�Y�tt��c6�HwR~�:qc.���9S��:�i֌ń?�V9�mnr�V��+}���p�*����U���.U��שsզ�,h�H���:桯�̜�]=�Ϋؒe���n+ux����m��&}o�����2�p�s3ybe�|�S�c�8����R2��qC�iVg8ᘵ�D��ċeV�(*����P(��-�(G�D����}�Z��ߩ����X���?�x%8��[�����, ���;��?X�����+� ��/��Y���wA����ܕ4������`�+��W��
�_a�k��_����?&��0�T�������gY��;�È�@������ ������?��!������?�B*��o�G���/��F�����/<������_`��m��H���������<?��q���_��$�?K�����X������X��������?��?����?��!�_��n�`�+&`���|Q@��ӼLK4aؐh� �D�WB��E9�?�{Wޝ8���ק�u�NW�۠�����8�}����H�@HX��|�ɔ��]�60S�~�B�T��ˈHe��)NfhZ�d!�AJN�0��߇�)���������������ð����Ҽ����M����xq���v�c�ӵ*k7Sp���v+���u��j���IնJ�!��3��EX3F�ύY���IZ7����&�.k
Ci�n��j�Kg+}G̲�|ǩ��,��t
�?�o�'������n��� N�1�?����;���Ԟ����C����4�P���;M�����������������l��e�A-+#/p�9�2����HM1)j���2�
�23bT&�1
�f�Bj�/|����/���8�g�?���gX��M��;���%�աG���_g6������s���]zԒwƍ��`����+�9$j�U���t�	5�-�c���R��e�}=�8z��͢�c�,\�Ȇ%��I3���J�0��������?�o�?U:���L������!��&�����A����|����cS��1�������������!�L1���t��������	��e�#R��1��S��?1��N���C�@���=��f���CP|�C|�C|�C|��q��=�?��8����z�m�cQ������I�$����x:)�ߟ)| ������()��@�~�����q�ggIw���Gi�\n�F#ݵ;����}o�?�׹����UU|ٽ'^���bwΝK�^��G-Ѭ�w�׼k�Jm��S�L��0���p�f\�<`+%���x��e��b?=b��Q��.X�t�V��н'v�{�W� ���b��r��O��l~Ǎ'6~�[��6b�j��|�5��=M��l���\OӴs6��iu�9B�j�B�,�m���%��U6�
B/�FLf{祀��Z)+����ݫ�f�A�*������(����{:�o�����_�b��׶�N�S{���B����)Q��S�����D����������������;����q�c�ƯG���k�'����4:-����������)������������*n��_��V�v�ҒBae�p�-M��S,P�
Q姑O?���^u)��ȉ�;�6V
�y�ܗ��	ߍ\�3����ȿ5�tfY��7Q�#����o�c�Fp���D��e1��Q�jG�kc�2ۛ1(��Z���I��vJd�S��8m���4�?���P��el�2�A�o�[��O������<Y⅂�)/�&U�.۝jϮ,�ڍ1(�')/��V�Z(Z�i�Ǚ��h ��r^�چ��rCn8r�Z�+�U��JYiUЃ��*U�-؇�Ek�xl�z����z�*��Ox�*���_
�ӪX�K���>'��,�*Ӡ<����P-���C��tՠ�SEV��*o?4�ȓ:_��b�)�n��&DI�S:�f��l��M���9�+�`��w�^v!jI���S�=�]�4;oKsY*�,緉�^�ؐIc%�Yn�պ->^��t������������p�z�c�������w
��<�������?��k#���Q��T2Mi�LJa3)2��*����Q8Uͨ*�f�4�Ҍ����VSL�QHH���q:��w���������2,O��`7��d-M���Y8���|�gϙEP��7w�R���73�m-��x�Hc��f�rw%�}J����2t�7�Fs�Z�xf1��:\Nwu��底�XA[S�I=�<�j-K�V���+�����y<:�����Q�����;�����N ��r�<vg��t
��ǣ����ZS��e�|a�uNo��5J��l�;�8�jM�É�jC��7��Ta�u�'ꍤ�ɵ�����k���O��Q�6TQ\Yr��-�ej;����Wf G�y�ݟ��U��ēe6�Q����{+���O���#�	����P�Ǿ�W�Sx�+��u<�������_���8��Ǎ��6�1�$�?�{f�1���;�f�������o�Wy�����Q�!-����&Gy����6��策K kk�g� a��@l۳{�  SU-�Lu��T	�	��= |s1��V��'�+�͔�m���ӡ3"���P�J��5i�s��x���z�իp�^�ιT�ZVr���Cd�5�I��Y��>TB6��w}}�|��^�hv�BP�?�����I�7l��2_L�z�
���S2Խ�\C�~F�L�vSg�u��v�nUԣ��qU8�`oJ����EB��2<�i��U�)��^�,;�<��h���*��`�Q�T�;=���swR���0��$l���JdҼ���j��{w�~&ЗB�J�W��u�nğ�A��+yf�Z�+���Xz��Kr1��>ў�C{�$Tѕ3O �4A���C���'�h7r7C��/J�<cd@��sY�:A�|(����vVw4脦�{.@����G��6@�L�dݰt�>,[��;Wi�>� ���[��/@M��˭ ��3ٰ.�����w٘�Y{�p��Fd@�@����� 5&� @�b��MX���'�zV�9k�yA޴��R�-��MM>J~u�C�7d�(�Oݎ���ߵP�gX�76\�B5�В�d��tn��!��1�_Xپ��MԾ�U�*�|��.󁌋�q�@�}���1��6���G^�q"����E�%4<��pٮ����z��Tajk}��D� �҂w��@�+�C��a�p�߁+#�����AOl�Q��V$_�!d��װ.x�����C��؃6�yC�z�~V���	+��oz�G�c�2������$6���-��"I����L�����V<����v!�>j�ȱgaep�X���^��Th]��������ć���>��m�4c��g(�Y��l�)�#���Ν�΍2n�}(�B�]$T�f��t����쭒";/���l4����vv��m�J; Ba՘�\C�7�Q�KՁ�V�;}�i��C��t �\KL۞����3<���v=Eb�m��.���lM~�G�ĵ�����AT�p&_�������J���|i��kv�f>���G����s|Ջ�cU��㯉��H��k�q�X�f���A������aŦaC���x�o�n�	�.#_�wԺ���N�c�1�ȨU\n`<�+�ڦi���INg�@4l��Z_"���~	R	�*�Э�~X~��~��0}��r����ԩ�繏ӥutv$ϭ@VU|��h6�5-԰[,x�7T���O�'�����x�����o�ؿ���,�>���4���(��C����A�bܹJ�	��p��y�Uo�|��w�W������ܱG�Wŵ���*�������	��NA�A�.��~B�7��Q˖�+1��ubg��T��Ă��Rln�S��;���khXp�F׉՟�������%Lrx-�N1��!�8��.�o�o�E�Pa8��9�=�Z����I}��CǄ���b-2�|��o�Ed͑	6�����vh�,��o���t������n-�{lK���¿j<b���ħ�=�#��R��o�:_<��������#Ӵ&��TZ�eYIqY�)2�Q:=RU8�4nD�2�0��,�)#e�M�,��2��o�)v����G��K�'2�p�Y���#P�=�OdW��@Nআ���V|�����~�%���tJV�d3$��ECV%�,��4���Ig #+>SXfPOf��� %�e�:\( <n�2�;���[���gp��?�ҭ��˷�f=��s����e\#�k����d|Ec�O�Mm뭜�BR]�jR���Vꅊԓ*WT|��l�vG��\Kj���D�ߋ���R�*u�����ײ�W����e�r�D�Rm7J���ł.^͝+��Wn��`�;d�������\��=���=��q�uԤ��:_	e��X�*�����H�I���>��D���n�k'ۮ�k[J�-��nr��x^��B��Qh���������&�b�%a!/�j�ʕ��A�E�T�ǜ�N�$�[��ګ�J�\�^�u�|�X^&�IgI.d'���ڶJ���>��E�����h�����zV�\],�G��vG����mM���r��j�F��N�n�;��S�z�	�F�C��D�
?(�� H�z���;R�7�wx�oKW��U�9�;��zW,�u��W�R��r��f�wUЇu��y�\�{��u5�M����� ��0/)��]��ԟ��w8��y�O��'��1��Jx+��9�4�Y����L��E��F:����|߇�����dı�=
�8�	��V�y�;�h�M<��C���[\�sc���yPv4;���̈́;��2^��IQ~���h�a)
�d����!��$�J*�;ƯmHK�$f�����c;���cX�Ms�nn��k'p���A�x�@���@�����02}1�;�\pd%�v�����M�(������>��?�N����?�o��nK�����og����_�<��/̶=�+$�!�\8�>j��:��r=�yx��P�Â�@�~;{��J�j
v��b��=���QeޔW�ׁ3{-j�*�g�����d�>a�3�N��hE��h�ZA�v3;P�k��_�
'OMQE#�������>ٹ	0B�\�}Ō��l��p�4 Մ��K�������z��g��k��Slx�{�C��04�:�21��N �3�Kٳ�=G��
 �B����	ϲ�	��8'�o����+���pSD������GF_h��� :���?�����^����W�^q�:�ku�i��ak�� ���=2�6
X/Y��-����Q�����D✴|��/���8��틋��r0������g����W\��oQ\���]Yo�@~�_1�"���رS���C�K[)j_�<c��@���;����&�#��{!ػ���w� ^���3�W��@P�i�=�\̓�I�wӲ�"��>��%��fYjuQ���i['��S+�0�d�|\P�K��M"G����t��(��P��|�o�2�h��`��+�T|Q��Xm&т0�!�03�ơ������/p~�޿��p���䒦iY�gb�HJzF�c�J�Ȧ���z�b�Z���X� W�D�'qP
�)�)a��^����$��H��H3�"/7��Jx��u���P��b�!���/�[6%��3�g�#��[��k�s����o��߾��&/��:�����8�%6?3!�W�P��ɮ���M�/;���ٶ]�Xa�;YA�s,o���Q����9�cw��зǵ��z~`�|��n�G�/���׋h|؏V	�P�BC�	TfКAfN������>ͥ�C��;��fy�VFЊ�O!�V9*��H|��[���� е�8:�ha޷t-����M�lqMU�]�P���Z�(��M�u�zC
�*Jh"P�3�t8�b�392w�/�8�/��1kz�w�gVW��힡�S�_�
��w�����x��d�NU��}����KD���p��ehh�>��2Fbz��*��" ��`�$bDke���[����k�%��0�ոd���*�D�\15���
��m���iS�Dȟ��It����Xƴ�23��>s:�Y:�h�-%��#�?3�`0��`0��`0����S�/a 0 