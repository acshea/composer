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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.14.3
docker tag hyperledger/composer-playground:0.14.3 hyperledger/composer-playground:latest


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
� T�Y �=�r�Hv��d3A�IJ��&��;cil� 	�����*Z"%�$K�W��$DM�B�Rq+��U���F�!���@^�� ��E�$zf�~����s�rn�8}�b��L��[ml!_[����C��Z���))��D���Aa�?-!I�<CbT��ň~"���|����8�M ��&�h�|�e����LK��x|�q2;������	s�|��j2��B;ç�ւuR�赑�#������K1�66m�E	��������CFG3��B�= J�K��y�0��fv��� ���h�h���M����UhC2�AySB��W�2�<�	�!d�jK3��ab]�+!�D6m�?,WJ��f�bc���n��h@�@�;���'�ٸy�Rl2iG&�i:Z<��7m����,��,��ڶ� �ވ�@�5�/,�`�&�����z�P/��d��n�!�C�&���UԠn-���v�2�a6Ud�[���gt��1u����Vv�]�V[Gt;Q!,�_vZ��b�(��(��D��jY�l��94�b�t�VY,��ö�d�
�c�wz��2����n�l0�m�@�k����J�`l�)va�H��'�f�-��'���ʘ�� ���p��>g ���&�+*�AG�����i@}`K&m׹�}n+�����}*����'|xp�ɋF���?Z�_PF��'���~��(_��7c�mD�(�5\������?<��`��8$��D�	+6X��+(ϾT5#P�V���c*��7����fR�I>_����y�RL��	�<����߃vW%��:��� ����_c�!�T��r~V�_��WS���e��߆J֑���ƃ�`����?1(���?���+*t�9���d��;������G3Ho#�X�l���`Α�a���:H�mz(F�N�mǤ;3�n��:Ц]�M�*�皍���4`x�S�lo�;~`�-y�p�t�yFic�[~ڞ�6�<t�6�Ϝ^��� �b�e"5�zgQ�0��H�Ѯ�#<�eU�JSi��oaݡjю|𦹍�V4vx=�;��h����>h*��`������G��c9�w�8@+�|�FK"y�p1PL
�c��y��կ4��藆Gp�#��ޓ�ԓA�����\m2>_Y���u=����\����I�DAZ��U�q��{��j���݀6hj����p�JL�04�>z)dq�F��ۛ[�5����7U�B�m��-N��wԛ<���.�y��5EiU���>�GqCB�&��?� a؀w.�Q`�d���F�'��q���ԋt��!k� C|5J�Og1=�@<>k�-�����Θ���h�i���y[�q�ݢk��cv��=��ve~l� ;�i`\��e�)����a��Oq6��������3�'!ǟ��ҧ�+R��Ѕ���٬����Ǟ� ��pG��.�#h!`!)6�64�0�l����܏��&cN�=`��xo��zs�Sb��!�@3�y��D6N�I'�7���s3<ʞ&����5 U����#�)�C@wj^�l��F�Хf{�Ȃ
�b�-�Zf��Hv�C���"ᨰ���(��/�̐��Z>�%�/J���������OJ��a\��=[`g4��ӧ]=ꎙX�9��fLXu�4�4)�5������w?A�p�l鼔(f�ʻ?݄�f����������c���K�Y�]/7-ǋ���q�X��_^�Gn���N  ��a!�q�-�E	�aC��F����^T�t��I0ҭ��瓏Hg�N�fKe�X>/gs��Jy~�'�f�]�M��R��C�h�+��1P��D�/��N��>�|΢�H��ށ�3	��<7���$̹����'�8�Ӫ"�?~|��R ҶtN�tzB' �i%LFد�<���i�  �$�_�����s��`'�E������
ѵ��������2s�M�!7���?$
��_4]��*���?��S��gF�4�,����m��v	v� vг�k�s�2C������X&�^��x��@���+(�ן�p��w^�Fp��+)�]��/;������"k���2��7Ew�� {pӲ2Ml�mS3l�h���st�Cj�M�u����1'{�?;���Z?/>%��1A[j86{��p�|wIO���g٨h��=#�9Ë�����_�U��V,�զj��X��3�̭�ii��i�X�:����l�Y�g6�UG\!�	��х�ݘ	�0F�E)XE`�2<�Ιj��3�;%N�`�4�Ac�r��m��}����4}�
Q�o����_���H��
���ㅈذ��R��GgD�з�^�s�p �z<��xz�q� ����2x�	ZAF�.��w����V'�,^����}���X�L�0Z��J�/��[�#�b[Z�a��zob�)>���Ǐ
�/�U���������ȴ�K��:�w%���(������vg��~H���f@���=dt��`,�j��_{VNi�P ��ۈv�I��,`44�m��B��?�����[���	���Mݥϖ23Eɵ{���F��l[��d�K�%��wL��h#��dB���8�32lL���9c��t��Y�1&���T"���{��Ta���S��J�3Ç���a/Jf�ե����)D�Ǒ��dލ-�j�P��/����	4�~�/F�������?Rb�z�ۗ�h�^p�WG���ai��������9�ᛯ���7�������Ô���'�
�$c�5ETD)k՚�l�b�Z5��Q�$I)V��$J�p,&V���`u;������|�M#ސ7���;���5�Gd�����+j�6�|���ذ�ikNk�7���X�Q������_��D��_}���s�g����o~����#�����͉I6���񇍧�o��0ED��`��������s��[�.��ý���������)����t����D�o��Bk���r�����ҭ�����Nc����$}���?h�M����7S�N��;׼���9[�m|�E	ª���jMP��!a��C5E�n+1)B�'"�*��$(P܎�XU�B�����5� �Vk�
���h��2�<H���l:���)V���e���E"!+������z�(�C�8����~�p�����iv�e�.���*W��Anfd���7r����e�J.���c���h�Ռު��8�$u���+�3��<&ϴx潡���iP�:n_f��[�S�X��*圽m4�o��Y)|Q
�{I�0�r*�o�7Z3!�{%�++��E6�+g��r6xB�.X�0�{o�\ī���MN�ǅB&�}s\�J�sd�����~!����YGi�ۧ��I.^pG~�˿7*���M��NO��m��z�������ݓ�Iц'a�̅�+�u�I�J�R?h�;�r���d<���>fJ9)&�S�D���M��BV�g����xA�4/K��1>�D�o������I�y8)��������qT/Vj�p_�OC��i�\�,z��&��h�ʩG�ș��e����r9~��%���j������{����s�W����vJ���\¢�R��B3�ؗ��y�h<��7��A�����n	���CSH�#9-�&�G����x82��	Y�˹T%�-$$k�yo$R����)���U,|4����d6�J�I�{�$�@=[/��#���Sq��0���bQ���x{��;���KH�hG�W���{��|*��!|�������Q?Ќ�#�1��l��AtsC}A#B�	8x��L���71��-{�+-�h�﫻}4������h����C��B"��������IG��11`?u�j�r�lf��dy���g�.�>T�P�l�� ���@LkV#O��C�X(�oQ>s��=�D�Uq�`�q��\4;	�P�۹J�*їW�R+��UT�I��J�P��i�+�{��VO4N�
�N�0��P�Ɋ�;H��B�\�O���9��=뿜�˰��M�^��U��f������<�e���,������2n�+�lb�����T�t�;�Hȅ�QHR.(�B]N�h�L��XN��]�ԝ�%�7�6<j��r�0}��5SHq�go��t1��X��mq��yevː��⁥u/��^ۨ��0)�ww��t�>���v�'��mcXR����ů�-�����ﰴ�����$p�g���l<G��m?�ui�������(ˣ�[߁������4d�Q�[G }W6�Ѝ@:4�| �j����)\�Q]�Ю؁�ZЀu��ċZVم����X�O�<,r��#��} �~gD�$nA��c�U���iS�|����%� }�@gT���,����%�~�ް��~�n[��A�<<#�{k.��m���<���Ge^�~Ĺ�၏;���b� [Gk7X��a&Yd���^D�4�A��]���L�ᬠ����j�d|� G` ��Bt��.4X.%RʈL��+W]6lz �&�Q�����65d�)bFu=J��h���ŀ�
]���ٔ��YD�l/�@����~a�� �����J�?�'A�.ol2��-�j��f�7<��v8���<��"�z�'m�ȓ��{�_{宎6�xgb����?|��'�\N����H�ܴUz���'sہ�CX3q�u��y��^������G�0�զ��Az��h�=�m�W��1��Z��=���91��P�W���:<M �kI��}0��<�"�ff��МS�x�e ���_�k���{ѓ
D����&�T	�4��A��EèY���2ƃC�ߔ�&��5���o*���I`ǰ}��N�C�_o$���n�8�Cf	�&k��ʽ�M���׆�.�f�~���y���CW�P���6�v�SQ���B�H�P7�k��2�C�J�ۡB���;�"�+�`�@�����L֔:��MT����1�\Eq�D��eH�P�t��뼂u]�?�a=�'tp�m����J7��V�D�h�#�̧�'�t��}1���G���r�?~o�Jm+��B�Y��Xc��L��)��G���-�Dz�o�B[~�#&i,���RH���%�q,-w�4������3�j���ʏ�Nr��ڎ�Ĺq�Γŕ;��qc'N�@�!�@K �7�݌`��,�° 6#�7���k�9~�y�wUn��i��{��>����7��A�{I��G�P�K��������_|{�W�����s��������_��7��K��q�s��,��8z����:�1�
�n]C���ga*Ɋ�I��"����p�)��B����12܊�BFe� ȶ�r���$��G�������7��'���G�����}A�������!������}���V����﾿`�������{���!�5����������i���� 톋! -V h1e��
l���F��cCK�R
���&�ҧL�s���r�B��{�����«\p�CW5�e�
�ݨ*�%0#�5�:�M��i%ab��&�^}.�
��kHֳ����=C��0�/鴍@���V��`r��x����|��́��u3A�w)��Ek�Nq��6�q��΄b�L�0�)7g���A%\��f3Y�։�!M3فyX��g{��;�5��~���:�F�}��_���@Μw��s�0���X?ŗF�˗ٱ�k�A'r�B��:�7��2���J��9S��2ee$�R�-$0��,by��B�Z�Nr �Q�K[�#��$�$��ɚ0�hg.�4��-�1����)t����Gt��"n*���� i�I�;
S�_-2�a����71�lѪ�H��b�C�r�`��d�j��X͔��qg��r��/O3�N�OִV���Y�T6�tr�g�&%��Frʏ�C
m!Z�K��l~�]���t�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%rW�%�py	c0�"o�R4x�$��?\�(%��cO�p���cLo�S�lӊ��b[���vV8�rr�D��A�C!U���A�ꉚ)��n����۩��?�n{���C������9Cd�x6d��FU,�zm��G�j���M��	����sS�<N��p�hjr,_���hl��6Y��V?��n�~"��>�ӱ0&!�2��-k9B�©�D��&ފ�<e���s�B���S�p,�#S.�|&;��ә2k&��j'�.Ȑ���d?�ӵL���Z6�'.�;��T�Q�MZyD�ڬ�����,J�K�̻��z�������oY��q�ڣ���-���
`�^�/���^	��g�{q�\l��a~���E���;G_�}���C��5�S�E/��7�@���˛�7�y��X��> ����� ��@|�?�ƣ:��<|�a�z���?�R�e��(������,'�*�g��,)�(��������u~��K�Ώ�|�2�`a9�,%r�Y���+���X�~Ʌآ�`rGt�Ʀ�	Lٕ�9 |�
L��H�L��(�Y)�aL��,�T��*0K<��L�8�>f�y%�+ 1*��N�� ��߬����o���E�M�����1o�i=ڮ.k�D����te�GM�&�9[�D���jY��I���d:u�N�t�o0"�i
�d�SP�8#5��@eh����v�8^9�D)9:�$�|���Q�J����>E�e'��Y��UZ�)�~��l�b�<TpLTj�p���,�F6т>��b!���Ƙ^`�8�e�J7�)Ǎ�0S�{�0����N|�ۿ�x�[W2M�M�P.��(ϗa��p�LN�L�����p�_����M9��+����]W?"W1�+r!��/�=n�e���6����3�{fVz\�ew���;m�]w�g��~��M��pĿ�\�C˞l�j5�7fI�g�D=���l���Ò�͠���Z(���2�g�S�(F�,1��\��<=���^mdi�T?�fNߡ�Z�M�P�lC9.дyj3K��L~Dw���@�:�|��$R�YGkO�#������Z�`��|�O��-U]�*,�.-H��V-�W����NU�bYs�Rd�F�P�7�yC�R�bQ��Ê�h2�l��)��"t�5\�W�u�~�1B��Q4�,<��M��W�DV�d�R$Bv6(��552����RHزJ�&�_E22���H�	�~Ԑ��I*�G0�2AVv��D��c�2)s�U(��{�B)���B��:���uJ+�9$O�j��pI�?��:ݮ�Y�P�;�<Ǹ�ѱR=�������V.�*�dH[F�3�.��Qn�PW��P(�r�.������piJ
^ԇf�����y�S�y�� }),����)��f�R��;�4YhΧ8)W�tC�k��<O�HX#H���&��Q�1K�:6�MS`��QXbe��Bl4Z�X)�j9�2f�����.����,��.}7���t�
��x�2���|�B��K�C�-*�1Q��b�#7�_F~��*C}����xxySi#/�c�g�huK�R	�x�y���s���σ^�o!��<��()�n�M�b���S����Q�4U�}H���5�I\����)I!ki�3�*��i�8"�����8Xɐ�%��s:�Sw��V����G8�C��D�uE��Gȇ���)z��p/r/�r��f�wHwI����D��z�_�����Q�-��~�����r�@}�l?t\�:=	�j��@��kH7�˝AM%�@/�r�ke��G���aU�Ki��]�ȍ;��� �H;�q9#�O`�E�O�#c��gv��~��������?uް6�B_ː�K���<~�:����>����غ]�-z�:@N�J[Ŝ���Ɏv�l>P;������cu�euɆ���ãqя�E�#~?zX҂�c�|�� Sk��~��B-� �g�+bw��/��7���B;�z�M-�18��b�`��I0�A�;�jrp�X:
 ���T���Ԟ���pe Y|�B�Al��ja�C�٤�$����(�Џ�����p�Dd-:����>�����Z�i�zW�x��L����w��~t�W��"5�Z�,� ~Ҋ�y֫������U'.��&;��X2����ں���x��U��.�#��+b@}�&:���Y,@'�L-�q�Or+! l��D�Ա���#�F���������	�˭~f@�����9���O=����3[��\;ؐ��_����bS��_��,���UM��d����s��EC��ӡ#�-��6���҂��u�&����-o�C�b�$4`en��f#�O�(�-`��ɏ ��$~y���|.��t��qp��"(�fK�-�x�Kv��V�>aP�:W�&���+���h�R����E�<����v ����{���]�LR5�2�U�?��!��q_j�%v�4a� ��m{[�'<	^��v�O1��1��_i P�P�X�A?MI�#�T�l����Y�I���k)�΂�������2k��I .�rXǚF��A�.�����:�v5`U;V&k( ?��=n�ܩ�!c���5�SK��f��aM�=W���v� �p?2m��_Y�LTI��%�����ӕ�s��Zv�E���]Z_�b�F��ދ޿ �>��	p�mX���n�����!�"T�i|��U��m��j>���&�ĉ�3#��ON|-3�Q��Ú�C��y�M�$p��:��u_Eٜȝ <t�ϟ���Ñ�n��mm�i��<�@���#V��9�1��.���E�[@�BSv6��
t"��{��}���f*�9����n)�pḡ|zl?�@�)����1����Zl�X����:�����v��+۸��?!6���v8��G+��$��l�dG�[V�`j'��2�6<�{�	�)��8}"c<C���Ρ�K\���oYڪbGg��.+>�%��5_�Z���>+W4t��o֎D���T���&��D��٦�v���q9��%�h���c��l7�1J
���DPҙ޷P{���A�;�
|����n�I+��fl�7��z����(v,�7av�}eq�*�ԤH��lb�(�%'�p�b�$QT8�D�(UBRS!$��5�ј�(�DI�51�'M;��	�96�O�O�l�,�m����)z�sKBO�;g	��dg�=�]Tleܵ/�Y~G�+8vW���6Wd��E�I.���Y&��p.�LV��������ei�-r��3ZW؅���%�$pb*�>�G�Wd��^����.T���<�>��]�D����@�g]�\T���#;���:hg��P}�B;�ѝ6!-m��:Ӻ*v0:�2����m��6��ӵ���vn�(t�	�nus���w���KS.&��(��{<W� �'�l�,�q�B���)���s�*��,ǔ��Y+��e�9>+>���	����5:�&�d:tl����>aI���E������v�l£�;����U4�+��\6�'ϲ�X�Okt�\6:�_�]ot�u���L�S��<-��yt�c��"pl�*[i����H3t�{!OY���\9�bgL�_��S�X4�B�����Q��3{��䳶���,��/�7��]�����������͢��m7�o��-ۅ~Lv��
�.+ce(�g��;�ڼwI a�R�nm��\��
ɻc����p�8b��r1c5�8B
8*:�����n�߮l�n�%Lb�C��}�;��6��h�����w���H/|��d�m�?DD����#���I|��7v�����������t�������������B����*��6�?	��>Ҿ�?�y�'�����lڗ����/Nn~�����}/����������z��o��Qz%�?rG�������/�O�c��l+XkG�2nɎ0���v�l)�ԊE�xK��X�j��H�	G�&&+x��Zg�ˢίvz��!
߶����|��f����4��5uh�ÑVF��s�"��є�0p��Ns�|]W��ʌ���J�s�]�� ��R�9,�"ch$[\�O�Ѳ���m��!iY�����I)]�M:�⤫��Sf5IƻcTc/����K;���*��������/�ml�}��v�}��m��q�p����*��q�:��}�}�����=��|:�������u�GF"���t�� ��{
��� �����?�>�9��{I����Wq�pJ��t����򟤶�?u���H����~?;�D���%�/��	jK�����}�C���c�ʺE��=��w��y�x���TDP�y��(*ʯ�4�U���R�+g_��TR�n�����Q�pT�z��P��=�����RP��P�W�������Sw���%�F�����?�����[
ު��k����J]�?gY��_u�NHe;��?�J�?}MHn���u������c���>��y]�D>������Y%D>}l����,����.�YC)��YX����kf�C�sk;M3+��\��t���=��w���Xzȼh����m�c����������m����϶�_m�L�:�^>X��ݮ�K�󄤏�2Iν�f9��[�o�>��n�\ً�0u�H�#'�]QE#��������4-��!��d���Ǧ����S�����r�*ihɈ1��Qf67Ӡ�������iA,�j ��������W�z�?�D��Z���p8��@��?A��?U[�?�8�2P�����W�������?�7������?�&(�?u��a��:�9�o]��{�o�p�O����U�X��N�߸���~u����)�sg<:k�ߗ��[����c�LC�z�I�V�x6WZ����v�VLw�k�=�K+N��kFm�dO�(�Ă��Ͷ3�gd*����fH�&gOe=�׺>�5>���� Q��\}.��h�J���������m㛗84�9��1�)pD%8�:.�K߄Rn��6ev�Nz���m��c�o�:?��&)#�r�D�5�Yg�g�⒑6Z�S�0�E-��@�a���@��2<g�dB�_�������O�z/<�A��ԉ����1������b)�d)��8/DC�c=��Y�'h¥'<%|ڧ����3~u��G��P���_���=G]�b!4[M�F�$c���;�k�kǼ�hi�m�ŗ��ess$��'�#��d�>���62����rrG���B��#EY$ǒd���&��6#*j���Iq����u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿃n��A���8b"98�ͧm/{;��,g�Sf�%�[�'��/��hЌW?gt�K�n�%����f���!�e���Џ�d���y��١a��uN�?2��d��
�����ߊP�������~���߀:���Wu��/����/����_��h�*P��0w���A������S\�_D��D�-�nxXO��I��X>M����E%�����[�a�\���g� @���3 �?�هg \������P�"�C �<�7����*�l��	��_�Kg7C�VSP���km�)�b��H�z�:���Pz����x�9�ތ݂����"r��まG/O����|�� ��rM��;!�[�E|"���q��4�h���H�<+��n(k$RXV��	��餭f�=o �\bk#����?�Ը���o�?i��5�y����lp��ИNՎ�ә��6HB϶��f�~���E�5C3�[g����~�hr��jc6�N��5���U�3�ދu��@���������}&<�2��[�?�~��b(��(u�}�����RP
�C�_mQ��`����/������������j�0�����?�s=�r=�CIe7���Q�s]��I.dP�fC����i.��˅$b.톰��i�C��h���O)���N�;,%���z�X8B�>��I�sr�oGdA��T�2�k%o�F��l��В��v�ö��٬	����|7飸<7���yD��M�G���CG�m��w"G:-k�G�u�ߋ:��1���?�������k�C���w(�����	��2P������+	���c�x�#��������U����P:���/���5AY������_x3�������������s���d�ĉ�\w��~Q���Ļ��o�����~_C~f����F�q�;���x�w���S-8ț�����k/O����ޑ�'�T/�=-͑���
�Mo91��=��*�����cJc�Is��MFɴ`0�R>��\]X���x��\{��s����v"����z�FP�{�\]oӵ�����P�Ek1ޥ:��#^�mQ1D2S�h�YӐd݂��\s�q��P�����;�A3R"�R�d�w�A�J�ԕ�\㘃�LFZg��Y$9������Xvi�����=8��"����|����������8F@�kE(��a�n�C��`��& ����7���7�C������*�����k�:�?���C����%� uA-����	���_����_������`��W>��Ȯ?���	x�2��G���RP��Q���'���@Y��x�nU���z���B������r�����/5���������?�����(���(e����?���P
 �� ��_=��S������_��(	5��R!�������O�� ����?��T�:����H�(�� ��� ����W���p�
��������W�z�?�C��Z���H�(�� ��� ������?���,�`��*@����_-�����W����KA����KG����0���0���.�
�������+5����]����k�:�?�� �?��:�?�]Ġ����P�a	���\8�I��9'�I�l�>A������y㺜K������/����A�_�T����R�G�����ݹT��?U�B�ݫ7`�*y�'�I���G#N��&6	��x�:�ZR�C�������E��bf��0��e�rE�Q�ȵ�J^!�hi��!u�Z���G�G�|����`��w}�)هsO�Xh�m�h�����IU���u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿁Ohԩ��[y��QSd���B��Ű}��-lpڟ�T޸/��.���\�E��7,|��+A�:H�l2G���J��SK�6��A�v�v1���6�l5i�'��(�*i�Y�2�C��^���w�;��%�����������u������ �_���_����j�ЀU����a�����|����O��o�O�&#B�;zcN�lqd��(~s���~��{�vWi'	�റ�[>ց�{2���g�7�q�mi��LS/B;����J'����v/��0#Ǫ?�����b�mgD����)Y�þ���Nr�^ۍ��W����t�����a��\.�-�������,��]�ӌ�A���#A�X��ﺡP�#�e}�'�~�����/��&��aN���$m~�1o2����<����wrf���5ڽ���'�m���(X-W�F��x��	�[bٜmR����}w~���]�^�^�������R�����?~�������:�� ���K�g���`ī�(���8��(� ���:�?�b��_�����Ϲ���Q?����������H���+o��%�|p�����ǵ�n&1s�0N�s���:p�'�����ě���,M����&]~ԭW�B>z��Ο,?��~�,?��g�r�������KW��u9�Z�W��Z��9�dl��/N�"|w]5AȯufwC��WŴ��+s #J]��2����2�Ō��q����rѰR�]�9՛���a:���d4o��=c�-�c����[�쓕�侹�[;wu���M��׼�n������!���ħ�D EF,�c��֖h�vS�n��MnD�c�cP�E��|i�,]R�X�\�H�� ��{��
XDv)�;0*�y��'�4��k�\�T�%f#R"!������)zp�^�	�io�#7%ru��sf_Z��������������oI(G�1�z4F�3c1w��c��a���J�(N�f>C��%��)=sC�����,ԡ������?��+�r�_���q�e{+Ed'�MG�`�.a���J�����{��g��|D�\�
�����������P	�_�����^���W
J����Wc�q�������?�_)x���W�����){�ط�X�.3�	��;�ϵ������2P'�ԓ�w5ؐ�y�o�~��xW�y��7�����o����C���D�7;�P`�s�E�ې�A�ZG��Q�5��ר�M;�x��X��4/�����v�?9$���q1Y��Q������C>���l?���zr���ż=k7�Q�a�n;��Jt:KӖ��Ǽ2]��<���x���I�ì��^�0�
'���/%J�R^���K;���S5��J�̐fXs.l�9�
�q�+�.��me6wg��/��:�?����������K���,��Č��k�ϧ/_QL�<�r1�uY��7�E,F�.�Q�G0�#���D�q���#�>���>���ku�u��B�E����BN�<Wj�D�*�}_�-������{�rU-�Ge���g��������A�]�޽�CA���2>��u�Nx�%���������%��s��j�����?�]���P�����?�5���v��1�6�^ڡד�^?���}�C���lMPn����>�
~t;�QZ��[��A$�ɒ	M����|֥�Y_%�ǔ�Ǥo�壅ܻu�����n�+����?}��i��޹?��m{�w�
nN�Թ���!=ur� ����֭@@| �:5����;�DgҙI���>UI�"l���{�����J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���y��d � 