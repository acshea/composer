ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
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
WORKDIR="$(pwd)/composer-data-unstable"
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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
� ��Y �=�r�r�Mr�����*��>a��ZZ���pH����^EK�ěd���C�q8��B�R�T>�T����<�;�y�^ŋdI�w�~�HL��t7�X�j�>���B��{u;F��k�O�L�#�0��BP�OĠ�Š&�b8(�� ��/ǲ�	�ۄ͚�����:ȴ4l���s�����Td�r �N���3�f�P3����-�;|�j-X'e�^�:�֑<S)��Ʀm�$���;�K�<ge��h&6ZȰH���Q1Y�?ʥ2�]�� ���'
�
ͪ�����-d�*�!A�����.!H���Xi[��A�2�jK3��ab]�+"�D6��;*���Ģj�bm����n#C�7�a �ŝ��~��l�<��6�c�4-�`�붆^�SS5��,��ڶ; ��H�@�U�/,�`�*�����z'P/��d��n���C�&�W%��A�Z�Wk!��a
�<lV�ITn����!-�ԩ�u���e?�����hv#BH�?���bA+TW�(�AG��jY�L��92�b�x�W]l��köۤ�*�cBw���2����n�m0�m�@�k����r�pl�)uafK���&�e�-��'���ʘ�����x��>g ���&�W��ݛ=Х�Lꃹdr����r�{�|�z`_u|t�'zxp4ȋDB��?
��O$��bHzB.�����o#F��ί~�q_l�C��_�$:�b0$�YbD�"����@E3h58;�� ���*�W�L�1���R��P<*�ɷ��>�y�㏠ݭ�O�:�$� ����_#̰j�t8?����������u��oC�	��aa�Ax��?y���(�d�/!�D��'ŵ���s�ཀྵl9�#�~�uK��f��F&(�2�О���-P�&Y�u���tS����ڎIWf߶�u�ME�M�"�皍��p7`��S�lo�;�`�-y�p*t��Gic�[~Z���<t�6����^W>]S�a1�
���I�^�L"+��h�Ϗ1HYѱ�Tp�k�[Xwh�ZT��»�l��[q4�ꃦ��:lk��;z�|��}~WY����Q������V54F�bRJ�����+�կ4��藇;m�#2�ޓ�ԓAR�����\=3|��`���z���o�$���S��%Y���d. %��^����?��Q�9��vڠ��:�F���;�"`:����K!�V�l����9�X��ܪ2m�>nsZ����H"�� σ��(I���60�?J�7�� �(�Da޾�ǁ��(s5�0�&��q��\����۰5[���ۧ��v �5����]DH{�Ea}v<���i�ߖ��[$�F%�%�"�1m�k�cmx(̖�mpALf֬Nud0?n�U����aC��_]��>�9���K�V��:h�G.H���f���UL>���(�;.��cA�H�A����Yd~<�~����r��l�{��@��s�2�9�P� �A��#��d���Q�,7�p+{��63�W TL��^��8ݮyu���K��ʑU������V�1�SEz��
w��	�"���J`���u�����Xb���Y�W8"YP��u��J����}7:s7�͌H�Fc&�y��iV��1MJ�8�`��%2��O�&\i?S�P�2ǥ�_�kB^5����
������r�9��ʾ+䦔X!�p�,3G���Q��ż@��cX�~Ibt�iQn�����k`��T�!�B�i�t%�|s��.Tn�[,)�҇R&�<*��K=�6Kv1�,D�jm�h�D�=1䶁��&�{�Ƿ�/���&K�#� ޾�3��	l���+[�u�H$��*����?J�XT
DZ��ɒ�Nw��׭DɈ������m� ?����"�+��f���l4X�y}����IBd������3�дr�����0��#����Wo�ܳO����2 �|���j�%L��P@oj_{�{���
�������!Z����?[��K��o�G�Iq=���ێ�}�����������u��J`��o�.ñA�ed��|	ڦf���VU���%�u�l�l�����O��8�����aӾ����m"�'��ņc�����w�t�>�z��Z�&�#/�ddBoҿޫ���X�M��ñ�g"̭���Tޱw�:V�N��l�=3[�g����ϙOՑP�-�=ct���G'f?�1b�E*�"0�Z� ���z�L���ޙ����k�}�������~p[����e�Df�?�� �aQf�?,���*����G�5W���/EĆuחB�>:�]}}��5?7H����@=���w����?�_�w�V�ѹK���x`GmT+U��m��>I��?$O��������]	|��jA�����T�B�A��Ą7�3?j8_p�t[���K����af�AQ���Y��\�����?w��Y��B�^���جHo>c�if-��k5���מG�S�3 E �V��0Kpx5xM��}�P%����ɣ����6z�zqSgi�oK�yEɵ{��n�`���l���2������+:&���K0y��қ8�$fܰ1u5�̛3&�O_�1�b��
cwaL6u�"�����l�������̻+e�>(<��xi2��.t4�E�BdxY��;��^�*���#~�p����>������HPX����<�#'�'�}�����PD��]�� ��r���}����������+��柟���A�e)�SSEU���V���N4�U��,E �E$��h%�U(GCѨX�설�N(���r���&��l�+��J��k$~!������tz�x��&�űaa�֜��?m�#�1��F����7�f�ȿ��7#:<����ugm����}����?�&���_��d�jZ��� �Ͱ`��h���W0����;�?�Ȼpw�g�x���K�,$�t�$.`��W�8���&o�c���n�����+�ko�5~�(]jhUR6\in!�'I_�F�t/~��ӛW�N��׼���>[�-|�AE�"�JMP#;Aa��E5U��QY
��
�T��eA��NF+b�(��P��ІԮy�Z�� m��B,���@<Y(eR��RJ��wF6���/�qE�וn&��3%�'��j ���7'�z���e�y��BHܮz�<$�fZ��X#?9�^&��B��;!�J�f�QI�J�O�����>SK��L���j+�I�ՙ�s�.)o\\J����s��Ѩ��Y���EE.�
tq����k�3[31��5�-���EFʖ2�Q)#�ҲV&����J6ou����I>�Nv_�����,�8ںx,{��R<=鶴P���<���n�/��wFYJ9��y��4t��.*W�Z6&0��=͟lxRH_�bHG锭�/��V�S)��IOƲ�X�c����J=��ǽ���"d�X��9����t�Xʞ��N$�F;;8�����B�ul�8l��D�B�v���5-���G����N��X��q!|.'{�z��T�f������&c�n���~=�di_��1���T.%�h���n���(�X�<�N$��E�f��=h}l��d�ё)�S�&��-w�
���`\�J6Y�g�q�:ȇ��d�c�t��x�F��E$�	��qZ�D;�j���Ca�ʽ�Uq
'�0��f����xs��?��֋��H��+��wS�d.1��~���8�F�P3���c��?�����8�Q$�?|$y&`��M��Ex˞�J�����n���s�}+�%�����g��X����8鸐9!�8H��ҧ\6��'s��h����.�1T>_�L��0v��@TkV�O��#�D(�oP.}��=�@�U� oHN��\qE)����/�
�l�y���ȋ����
�?��f��/�z���B�})���S���S:��U%�(;���~I@-�6p6���|7��{�ˁ/c��o������
�l�S��M_Ó/c��f���u��J`|�/�3���?��&�g���G\��BJ^M��JF�f2�(�R�u���,����q+���G��T��D�S8㜤
��
>i���+۰[�r�-�{)D��F���	���7>�OK��{���`����ibIM��{������^����oH^���j���v�dy��X�|3�~��:(�2Ӌ��{F�,�o|�>w/��!s��%x��p@��GnґY�x�	T��eL��ꂆv�6�-Ђ���O��%`�*;��"��CZ�a�Sz�G��9�#8# $pj�.˯b�͛R�m��Q,"�kڋ��t�e)H����F`��G���2�1�}l��/y����<hﭵ�f�=�
$y,��������Hs��[}�~٠I�4��n����7�"Vt�� ����M�jL�hf"Mg=�=w�vL�W~ ��/�@�`�B�]�D�@	��6z�Z�K��ÚM B@ӄ=ʐ�lSC��$s���Gy[���]�T�W={{6eq l�GG#ˋmPj0�_X�(�K`A���{����'}�W7���ˀ�6��NPn5�k��v؃��<�VE��	N�ϑ��z�_{鎎6Ixw��}�4����o�&���B"�ݴz���'}ہ�CX3q�	C�<$MI͡DL�����jSE� ��4��ӣ_Ø�i-wP��Iɜ�_�)�#Np���c���ZCV>z�
R�D�]#+g�Hh�)�z<�2����/$���ѹ�I"R�hay������ Eآi�,sY�y�����oZ��q��՚�M���*����cǰ}�@�ΰC&���.���UqTB6�-Vi��{���W�n�6��l��m���̡�;t�	W�l�Qm�>5���o�'L0��e}#;v�:C�1�R�c;�C�SQu�"VD|Š���`����\�{�5��u�)m�u�/W�D^6��h	�>T)߮6�ǄW��k�G:�GҜ҄����W���M�}��#�!��]��:L�>���⣙S�bw�?��g�Zb\��rwO�ɝ~pa�p��F]��Gl')�Jc�N�T���dQrb'q�yT��I�@H3�H�b��`�،@�� ,b�����Q�[u+���iu�*����:���w�5
�5,����>����(��� �A��=�wc���D���U���6�� &W�q��'#�&��&��w/	y�0I}I�������\��oO����?��L)����������g��]�G��#�׎^���o�b������	M��$�EU�d2�D騊�X����Wi��Z8��v��T*��Au�X�P"�/�
=}�+���_�y�?�}�K?��O�V����g���-,� o�P�F�?}�] ������.���������B����|���O����߽yh7\h�"@��-V�2�|/��z&�V)�b�s�v���y�P,r�9��*��*\��UM�m;�{bq7��o���A`�E�A�SdwFFMZ�<�d�1ϋ�xޔ�g�Y���iq�X2�֐�*�%�❡	�5����9�/Z�'�V���Ҽ�K��ni���q����R�JZ0�)?g����A�l�p���LD�K����<��s�2�;���~������}�XX�f�@�^��,j�Mʴ����8ŗf�'T��n��$�b��>�2������5SS�
mg�zr�#&1��,a��FY�^�nj 21����#2��&���Y0��d�X��-�1��I^��)��/��M&?���b�43�����(�G�lc�����&F�+�U���XL�Q�rn���&2��tjy�e+��;&�����촛Ru�]�hyV+W��ƘٸEK��ٟ�
cU�bG�U�2�:��b�G�-7�{��z��y��x��w��v��u��t��s��r��q��\^��ț�4C��?):��2J�j��W;��.�8{���\����p��v���vV8kJj�D��A�C1ݸ��A��Yi��~��Z�۩��?�^gY��C���f��9Kd��x.bj�fM����,)��4�WZ
ab=�h���LVd�Y�t%^�Opb4�Fr�*�׫��?ϣ~���9N0q��x��͖�<a�d:/3�KoG��"��u���2���ȔO�i�T���[��Q�Ƶ131��'���23Nϥ��ʧ�U��4+�I��(X��;�N'1������P��׷C?w�z���Q�-��7�^{�6���Z~lu���%�{c7+���.�~¹� �|{sX�Z{�4����BG^�~���P�{��tًG?�;:���f��k~.+��Ao���?��7��G�Џ���O\����~� �{����_+ʲK[�)�J�fl���-��E�����io�|Yz�:?�1eO�'�M�o[IG�p�E������,��ӓ\�m���B�U���+�,sS�E��I�<�A&JMb$��v�����Ȳ�c#�YN�%�LG�t��s゚</"q�@�f�J|���Lh5��� +4��^�f���6�)˜7Iƈuj�� ��j�8S�1�KLޑ21��Z��D����n��3S��� a�F����56��-~9�X�jL��:NT��QSN�.l	4_p�dyԫ1B��dN�5E�ͥ������_��Z�ԫU��z�����ŨZ4���Fl#�+���3�\G{�P푺zܜ�5�<C�mA���d!D{���G�q-�$�����b#�
BeP��,���WZn������<���4��K���� ���#�sK�9���\c�;�9����#���<��gV���z�ܖ�=vG���4����_�ߪ��b�f*	n!����\1��,�������2�i����aY�e��~M+V�jm��s$��ٴJ�f�7WE��cZ⼏6s]n\�r"o�P�*#2�c(󎡜�:u��M-a�tk��H���)t�����w���Z����Ӊ�.B����M�2▪.���B���i�+��fUͤk}����L9:� l�#X��)��y�$���$2�J�:�DZ�(�i�ɗ�=���p��Ej�,�O��&��ky"'E�X)17�ú��x��*=9"nY%V�ۯ"Y)�U$�g?��m�`Ĕ�	r�#O� +;�Je"��1O���9�)$��^��3�H�Rm�&����<R�N�ڀ�O���	��ԈجY,]�_Kc\֙x��C)���9Z�TF�^*�/cә�Ė�	�(�U(��Qv(�h%ې."�l�b��d/C�����t�:>W�y�� }��҆��
K��Z9��]2C[�)N)�Ӕ�z=>/0�B�����d�
*�Vy����e�,=7�K�ɣ�/�f�]����b&�.����_}˶��wC�M7��ۍ7/Y��7.�����<pmђj���*:�2>�E��i�:4������Bo!o#}�gy��+��^Y[���Co!�={���ٳ���[�;0��8J
�zy�Xyv��:�aTe]Sw�qCo�z����佴l���������G\���1�p�l�n�2��9���;�_;}��. ﹋�(�D5�Q���G.�)�)z��t/�Rf�y����n������͠�0]���#[��q����t?�_��>~�	���Gݿ�9��Q���5����΀ ��V�|%ܳ3����#�E�)�*���<PM�.v�����Uo��f_���'0���ϕ�)�3��U?��vW@��wN�o8Ua�e�ѥ�e�p?[���o�Y׋llݮ��V] �_��bNvt�dG�~���Sx{��;z_D]v A'���i\
"A@���?����� � ���l����P���� ���=��}���4{�@hg�����ðm1���uA���^:	�3l�FS]	U[g�A`�[��_�:�՚����/��Wh5���-LH8�4�?���]�	v�0� ���Ewz�c����[G�>�BP�*�:�i����Y���j8 �@�X+�� �O^Q���Uؙ�U�r��öB��D��f���X��Y��2����ڥ!t��|Eh��D�8�!ۀ��`��m2.|���In%�mX�hö6���pid�(�"˗�բv�Wr9�|��B���5?V7g}a{�u�|�a�a�7��k��૵U �v=l*t�둟- �<��	^ ���z�ڿhc�z:t�-> ��ŦB�4XZ�z�.�dp���!��{P,��̡�͵��	�l�P8�@R����q��$�s�k@��g/"��B�m��r~ض����M`e�%�{%k��ٺ2��G�8��/�}��*
�q.80N�� ��.���e�a�g��;�1��8�x1���r�/;�S�	���i��r�8�q�����]x�v�1�����B�~�i��p�y�m�B�p����BN�^;8Hv�nl��v�a�(X�Hp�W��:�4�<�N� fv ϵ�t���ڱ:�C��@�p��nm�ƴ�y�ں4�.L{����o��������ୃ"�zu�ɺ=,e��UǞ�D�ۄݲ�p<�`�
��[6�7�_�����m�M�[o�V���Z�h����6��L�o���n;�V��v5!N�O�9|rh����@=��5�5�n9/ �C`��ueo*��%���B�����u��kkCL�D�	f���ı8����y�i�uq�/:�������45�ܿ���8�6�P5�Ѥ�ʍuK���5�c�Qr@q�Gw��Ov��k��c���������C�\��5���(Y��������o	�8d�O�O���v��17Y	����  ����Y'�$$�����U�6��:�&w,�*_�����E>���x��7h|�k]��1p8�d�^��)�x�vd�P�N��[�,��h�Pe*�F�Mw�m��+�.�D+b�'�V�Չ�2I�T���3��2�����+N��̍�c[����v����8o����	*�r�Q�X:�������r���V���1,��
N�d��,�4W�X������rĞ�X\%�*.ӲjOL�qˉ�s���c�S83�n���z�>�޹-�'7��nx�3��.*�3���,�#�5�+��l�/q|ɦ���KL�,�Oe�*�}���i��lBY�sǕ�r�)�+����߲Py)��£�k��f/����kW*�d�rA���Ǯ�"]mua`���.x�� ��ޑ�)�t�M�;�j�1i�]��M[����j�i=;l�}��vH{�L��Z����v^�(t�	�nus���w���+S.'��(���{"_����\���B��iF�%��*���VR�Y����
y!'=���	����5:�'�d:tm�'F�>aI���M�W��z�v�l£�;q�ĩ]4�/K�|.)��r�T˗NE{tO=6:^�]ot�u���L�S��#��yt�g��"�\�.[��w~r�İL�� !O9����|%��XwL�_�yS�x�|���m��(x�؝=xg�iG����	��A�.cj��N�i��|��f��Ķ��7����B?&��
|kWԱ:T��Շ��Gm�;�$�0�c��v�]-nv��ݱ��VD�Cq�Y������
���^?���n��nl�n��&q
�����C��}�;��6��h����i�����#���ߒѷY�������M��������}���S7��m��>�����^ҫ �	۔�T�<��}�}����O/{��i_����8�|�]����{I444/���f��J���G��u�����e��J\�w��a�hL�m�A���D�����x4��U:��:�v��FZQ2��0E�IBn��E�_��*��#4�m���%��0�����׵��Gz��/��Թ@�b�ą.:�G
C-̫3^���ITD/�N�o�h�O7f԰Q���7�\iQ8��*�9���%܌��Ƽ�O�Nʙ���[-Mzz:Q�`quV��a�7Fu��؟������WA���_^���`C^�8iw�����������^�O`;��#����/�	6�e�+��� �_���:��?���9Q����+�{�F·����"�"���� �����_M:�=�3I�;�Lg�+��$��b���^�q��U�f��Mj��|j �����׋}��������*�m\����_;�3�=����U -���/L�V������?i��������:�N8��_=��S@B��?a�� ��B��� ����H�?s7��_���(��q��IP�W����V�G�?�?�n�_��8��B'b�[H���e-���!�/���m������s��1޽�y[��޷�Y��YL=�o��e�[Y$�N%�_��V�݋���v�f���s(��4�u�<��U�u��b�ߵ��Nc`���2O6�+NQ{��d��{�/k�؏�}���z��j�!��w�n�y]�X�4{��Iz�M���"����)_����]�����;��)I�e��8��|*�R�cYkO֡˰�il�������)X�>����E��Ys��v�w3�����迧Q� ����[�!�����h�?�DU$���O$��S	 �	� �	����?�_@@��I��u��ϭ�������_����H�������B��������Z�_��L:�bz�,���:�n�����V�����u�����ƣ�!�}Y����:n�5�i@��`��CymĻ�`���H�i�ޣ���eB���FA�4I�B.���:cvN���>���no��ij�T�c��#����^}�	�Q,��~)�V���_���K��m|�����u:!;%���;�ewŒ�HI��t�2��^2)�l�5���b"��3�ǋФ%i�_���	��V`�|�	��c�td�6�����߀��#�?�_@@���K~H���5 ��ϭ�P����S���+J�?��b�,1cx&�yg!�����C>)��Y.$� ĩ�J�<�ጀ
��(���j�+������s"��f�i�X���i_
�l#
�Tt�-c�����%������=���)P��	��^��H�Y�.z�~59�S�M�-%��S�<VEq{|p��Y�5c&n���Y�g��+P��C�g}���XC׷V�p����> ��0�S����ǵ�����@��������;���u�qڎc.���7��b&�W����!cGyz|�����Ց�	盗��
��m�T�\`��NBY>{4���a�S�)Uܑݸ��3?6{�)�"cKq�n:��@��V�q�'���	��C��p�;����0��_���`���`�����?�� �����E�����?��꿘���?��C[�踙p��B��z����ϖ������%�����Um-~� ��ɟ8 �V�><�*U��h.ŇJ��� �u������f�wH)�L��
_y�96h����-�^k��meؖːl��p����cv�@���B����/��,c/,�س�q��%�r��^�|;�r[RaH�z`/�jK��OL\����>鋝f"�}IJ��aߍ�r��ϛ�>e�s�v�ܐ���ZRCnm��7ъǗ��1i���'���Z���t\��V���e(5�S�#%�t�h�-����nDg���i	��N��E�Xq}ؤF�vƘ/�d��e�t��\D{� �G����
|��?�a�]Tq�_�����O�?�|<P������JP	�C�����4��v������������z����	��?B��� �i�f�� #:�}��}�����y��(?��N��)���BDs�~����G�8�*�������qUj��L7�!1&	��H�ϊY�s7�K�4��b�/��P	&Y�.�]�K#�jm?�:��Q�톒�Y�)��>N���_F,.��Z��9;<v�%��x/��r�}�ڴ`���@��O�����|<��"�~���C���?K���W$�����a��"T���l�@�;� �����I�������P9������v0"���4�������������u��<��#�q�5��%�pI������wX�2�������J��gf�o�a?3�}kec�8�]ck<<�cF|ܩ�<�������ϒE�Wg�1Fi�ę�d���́U�x�t�ζ����НO}]�[��N��<��
�7mNˍ�`�z�ziǅ�t�g�t��r���۵���ƹ���󏜤I��V���e;
5����r�5��th�?�OeǢ���f�t�[,&��.p��������b�58Ec"{;v��p�g�X�mFgӍٽ��V�f����ml22:O.2-p���E�ǲ+
�����ߚP�����Q���[����$AA�kM���a5�P�?��� ����7���7�C������: I@����
����P9�?=  Q�?������ ��B�/��B�o�����8�*����c~��u�N�cTq��S��P�W���������U����-���������5�?�C�������x���� ��Q#����k����/0�Q	����U����?А�P	 �� ��_=��S@B�w�/�T�l����?��C�����������ZH@����@C�C%��������?迚��C���?��C����_����H���h���� ��� ������?V�_��0�_�����	��l������J�����@������ ��0����������#�?�_@@���K~H���5 ��ϭ�P�����PP����� �86��!�S8?�h�
4IE�����C��C��9_����������@��)����&|S����Z���N_��v�Zq��T�Jm��oހe�8�����ISHV�y}q���$2�����n)QXukKCєEq�?ɹ���pWe˗�F9�7�:mQ�ѣ�{��̅i�#�u�vˋ��Mӣ�'#�Ŧ�/=����&��Ej�_K��U��P��C�g}���XC׷V�p����> ��0�S����ǵ�����@��������������S�[=���<�;������g��1S����ωV�h�ͲI���/�Y�>*�|��1��Z��sK�5��Q
��v��f綸�eЧȬ8�kGe�]*cB��V�q��;��ߊ���?�����{�o 
�_��U`���`������W��� ���_�G�?迏�k�������S�I�tD�cy�n퉕/O�[�o��Z������&�ɓ�6���:{K�����*s�fC9��K۝i�x�����Ɖ��g���OD��Y|��c=���]�eyvs*7�Kҋٌ.�a����h�v����w����t�����嶤�����-��������,�'}�ӌ�Ad�O#I	x�<컑Tnb��1sҧ�~nҮ��/���Z���΁�cq!�`2	���i�ya�s�����Qh�{+OINf�z~��x�>4f�H�q֙0�踣V��6c�����wW�'�?�Ϣ�������[��,M0�m��9
��o������o�����	
��� �������w%����S��x!�*����?��p��(�?���_��
T��Ϲ�������������ς�W^��LG����k��a�6V��$�� �7[��qׁ+�W���~����i�~vܔ�z镮����a��'�{�/����
5���-�[��!�/���f]ޜ�[j	�ml��)�8����u5$�����-e��P��Fή큊}=ި�^m�L�sq>&��g�ZL�e��-
��l2ҡG���u�ѢM�K�xJ0�\�S�/&��n��OVޓ��O_ڹ��e-�x����8x����v�OY��!?}&fJl%�,qno�쨆d��e�G�0�V�=5;�XF�9T��ʧ�����Q�T1��E/�y���.c�#��Fc�s��D8����$�݈�XJܦ/�y��MP{>X%�M�^_�ǂ�W�}����^���c�����[��\��KP~��y�&}aN��}�fCa�����?��M	s��6dB<
��f�G���~����`��������b�;�A�S��~:
;y���0�|F.<)�2�/W�U+�{��M����[���������C0��U��Q����JP���?�Q����c���X���5��W��?�����S��i �/��'�l���S���/uj�<y7�{����s����f�ao��&��x���������YTr�;�T�wde��P�A�ZZ����I�	��op-�v�x��YQ�Q�g��p�h1���r�iu�D˺��퇽��{�������&��f���ݐG�;��t'j���L[v���tU�:����ItY&�p�f3"p'�p�jҿ�(1�M+߬�"���o5��:�sK�ͅ���:jx�mo�-�t3Ԍ���_4n���}�����G�?��[	*��3>�a��<�Ss�$o���>b�(��>������W0�	��I��>C������������Q	~���갛�MDF��;灃�u��ƙ�{\)��*ZgV;����e�M�`�-�����������(��*������{�����U|����/���$�����������s���AU��������H��+�k�����y��5�65��XƱ�S�^?����}�C���\C�^�zߟ��*��޹?��e{�w�
o&55��s�Sӷ
<��y�V��@@Q���x<&'��<:a�q}��A�-|�Z{��67���X[�Υ��~���&��Xnզu!�����=��^��{�h!>]f��o����\a�KW.�����a}��Wۮ�e%���u�J���Ǒ;�w❭�:Or*E��:�պ��7էRq9v�������'3�%���JЌ���Ϋ��bY��ӟnT�%F7Jx�\�K��?�����%��ς���s�x�oѾ��P�]o�w���ٱ�iڂ�2l��yd�Һ*��O����ҶMcR��ld*��r0���gw
Ɨ-9Yk�YKl�{��rvm@U��d-��+�,g�!��~�!�
N��@��~E9����4y���[�C�O&d��8�y���������:��������?�2�g�B�'�B�'���������p�%��߷�����td��P.g��������?��g���oP��A�w��~D�^��U�G������6�B�٫��P�3#������r�?�?z���㿙�J�Oエ� ��G��$q��?eJ������G��ԍ�_��,ȉ�C]Dd��_W��¡�C6@��� ��\����_�����$�������r������y��AG.������C��L��P��?@����/k��B������r��0�����?ԅ@D.��������&@��� �������`�'P��kC�?b���o�/�Oݨ� �_�����T�����d@�?��C�����g`�(���y�b?4��G���m��A��ĕ��?dD.��`H�0q���iͨR$��u�J��ais�\�M����A1�e�U-�BS&^��2�3���Gݺ?=y��2s��C�6���;=y��E��8���R��E�ŷ$����-���_��׉��%<�Ncݮ�0ǵ��e����*����I�U�F�|3��o��ǝ��-�j�$yP��"Y�7�JT��ھM�%�
�\��]��i
�_�zk���u1f��f^y����+�u���Au������]]��y����':P���
f}�@���Б���t����>�n �V�_������{��f�Hi[�u�qi��X�6�I�0�q���j��m\_l�i���5�Ѳ=Wۃ�Z7B��o��51�i���R�F�U�R�m���(�M����ӋC,-盅2��9��B��$Dڱ����R����a�(�C{4�Q�B�"���_���_���?`�!�!���h������������������qX"��zVq�J"�g����O�����k|��ID�/�O�@~��`�z���e�o��q��q�ݟŇ����cM�ۺ7)��܏�+7l�[s�X�jj���d�i�Z�ܴV�<(k]m[�D�}ء��B��G���s��駬c~��?�r��x��쐷�:�5j�i
ɔ����w�q϶���D '��b��D�ƹ��|�M>��'�6_�sE���G�݄At%���YUR����1��um�%O{~��VbQ��z�P��$���b�n�UR���ҥ�a��!�Z��׸����|�Ƀ�G�P�	?����=rJ�������8�Y��go����Y�����x]�����������i�����JC� w�?�?r�'n����O& ��W���n�{����S7�? �7��P2{������x���������P��~Ʌ�G���/���$R���o�/��? #7��?"!�?s��K@�G&|6��x���>��qe�D.���Ud{fnW�� ��#�w_�?�9��X�}[���9���e؟��8�~`_��;i��K�o���{���,�[v�~���z��2�kAǬ/�X��P�]s^]j{����Qt�xg�6�ᄵnQ %�~FqQ�'�b�r��Ni�ط��^�~�y��.�.ϕl�ZRQY6�$����P����3�����5��y��;1��D҉�3\�G>0',���ac�^�F��01�fzԖ�^xԭYD��=ӡVfq����B�J��Z�K�Af��������d ��^-��-������˅���?2���/a Sr��ߨ�E��&@�/������Z����D ��>,��)������˅��8�?"r��7���M.���G����Z��������͆sד*#E��������}�?I$�2<��uoe�G�K��� `/�y�P�E�zuw����H�Y�k�QbX_Qf���o��T%��-�ͨ���ί��>�zN�<rJ�Q�7�L��}cQ����9 �)	��� `�$�?��%\��d{�\��p]B�v�x1wL��l�aGYt�Qu�;��w����Z��C���Ks;M�,���D��3LQ�&DWMt�����o&�qc����	�������n���������e�F��2��G��*�Z��,F3�jE3�e\'-�J'h�"I�R5i°p��-�6L�e�j�%��.�Q���L��������s��;c�.�U���,`��HBՈŨ׏&�^[��usW���?Ń?!K͝]4�P��V�c)����
����8�]�4u��+̱���q�Qbw/����Q�%ѲB�I�C_t�	����������@����B� wN���Б���d ���E S7uS�%y�����=��`�]��E]�H
_��X�����W����U�;-|������c��2��|�zԪ$$�SsLcA|�#z��G�� ��A����S(fܖt��X�W��(8��UdM�E����������Y
��,@��, ��\�A�2 �� ��`��?��?`�!�M���C���������ߓc���u�Y��x���������=��o��.��(.�h��D&�hZ�(�lPT�$R���VӍ�S7GU�Hͧ*�,��Ŭ����O�.��buhi��i��7�ʬ�n��j!����fv��x�K�;��V��Ly�;lp�iL0����'-��|�VIdz�%{�*ɋ��ReA/����h�1����x�)��x!=_�7�r6QV�KlHO���m��"�I�@�$b^���S�H������xF!��ae��5��D�ۻ�'�hc���j��0;b��#Rq�fcfw��)�#��*��3�Z�?�}}���������?N���G�ORE��g��;�M���1C-6/��/�w��m�*�>�øP���,��һ7h��3�a�����pA�[��,/wN�l*H��DnTx�q����o,������Q?m��#
��y��r(!4��ys�}P��fz�.��Z���|>�?�/}�OOI\��9_����#�9��a)�,��!Ig��ς��WIw���E��� �ݸ�{���`����������Ĭ5o=b��]����F�9}��ӫmhb\Oh�򟭧�S9Y��td)��B�c�fz���{���ɽ_޼�G��N���?����<�o�뷇=A�_��~{S��7����$��UzT��#�������;���߅y�"'8o+<X���>���^�K��p�mPx���>��v����8f�2�ΏS!��OW���Zzx�:7}TH�T�­繞]X�����Yp�hk>�������~��JO��m׺�f�_x��}â�i��5=������<_sz�QL3���&^;��o_�/�C<����bqO�Sa>5wɌ����J���ȟNV�]��N)m�W���U<�7����:��{��w��Z���N��$N	��$��?���o��a��}�?���n�t�?>�ﲏ                           ��y1i � 