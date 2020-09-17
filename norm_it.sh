#!/bin/bash
source ./norm_it_srcs/colors.sh
source ./norm_it_srcs/options.sh
FILES=$(find . -iname '*.c')
PATH_TEST=$(pwd)
for OPTION in "$@"; do
	case "${OPTION}" in
		"--help")			man ${PATH_TEST}/norm_it_srcs/help
							exit ;;
		"-h")				man ${PATH_TEST}/norm_it_srcs/help
							exit ;;
		"-test")			OPT_RESULT_ONLY="1";;
		"-all")				OPT_HEADER="1"
							OPT_TRIM_WHITESPACES="1"
							OPT_INDENT="1"
							OPT_SPACE_IF_WHILE_FOR_RETURN="1"
							OPT_EMPTY_LINES="1"
							OPT_VAR_DECLARATION="1"
							OPT_GLOBAL_SCOPE="1"
							OPT_RESULT="1";;
		"-h")				OPT_HEADER="1";;
		"-t")				OPT_TRIM_WHITESPACES="1";;
		"-i")				OPT_INDENT="1";;
		"-s")				OPT_SPACE_IF_WHILE_FOR_RETURN="1";;
		"-e")				OPT_EMPTY_LINES="1";;
		"-v")				OPT_VAR_DECLARATION="1";;
		"-g")				OPT_GLOBAL_SCOPE="1";;
	esac
done
printf ${BOLD}${RED}"  _   _                        _ _   \n"
printf " | \ | |                      (_) |  \n"
printf " |  \| | ___  _ __ _ __ ___    _| |_ \n"
printf " | . \` |/ _ \| \'__| \'_ \` _ \  | | __|\n"
printf " | |\  | (_) | |  | | | | | |_| | |_ \n"
printf " |_| \_|\___/|_|  |_| |_| |_(_)_|\__|\n"
printf "\n"
printf ${WHITE}" norm_it --help for more informations on how to use it.\n\n"
#add 42header
if [ "${OPT_HEADER}" = "1" ]; then
printf ${WHITE}" Correct 42 Header missing...\n"
for file in ${FILES[@]}; do
	vim -c "Stdheader" -c "wq" ${file}
done
fi
#clear white space and tab at end of lines
if [ "${OPT_TRIM_WHITESPACES}" = "1" ]; then
printf " Correct spacing at end of lines...\n"
for file in ${FILES[@]}; do
vim -c "set fileformat:unix" -c "wq" ${file}
sed -i 's/[[:blank:]]*$//' ${file}
done
fi
#reindent the file
if [ "${OPT_INDENT}" = "1" ]; then
printf " Correct indentation...\n"
for file in ${FILES[@]}; do
indent -bap -npcs -bad -npsl -di1 ${file} -o ${file}
vim -c "normal gg=G" -c "wq" ${file}
done
fi
#correct missing space after while/if/return/for
if [ "${OPT_SPACE_IF_WHILE_FOR_RETURN}" = "1" ]; then
printf " Correct missing space after while/if/return...\n"
for file in ${FILES[@]}; do
sed -i -e 's/while(/while (/g'		\
	-i -e 's/if(/if (/g'			\
	-i -e 's/return(/return (/g'	\
	-i -e 's/for(/for (/g' ${file}
done
fi
#remove multiple empty line
if [ "${OPT_EMPTY_LINES}" = "1" ]; then
printf " Correct multiple empty lines...\n"
for file in ${FILES[@]}; do
sed -i '/^$/N;/^\n$/D' ${file}
done
fi
#align variable declaration
if [ "${OPT_VAR_DECLARATION}" = "1" ]; then
printf " Correct variable declaration...\n"
for file in ${FILES[@]}; do
sed -i -e 's/^[[:blank:]]int */	int			/g'			\
	-i -e 's/^[[:blank:]]char */	char		/g'		\
	-i -e 's/^[[:blank:]]float */	float		/g'		\
	-i -e 's/^[[:blank:]]long int */	long int	/g' ${file}
done
fi
#align global scope
if [ "${OPT_GLOBAL_SCOPE}" = "1" ]; then
printf " Correct global scope alignement...\n"
for file in ${FILES[@]}; do
sed -i -e 's/^int\s*/int			/g'	\
	-i -e 's/^char\s*/char		/g'		\
	-i -e 's/^float\s*/float		/g'	\
	-i -e 's/^long int\s*/long int	/g' ${file}
done
fi
#allow to run norminette in script
source ~/.bash_aliases
shopt -s expand_aliases
#end of norminette call
#look for printing alignement
MAX_LENGHT_FILE_NAME=0
for file in ${FILES[@]}; do
	if [[ "${MAX_LENGHT_FILE_NAME}" -lt "${#file}" ]]; then 
	MAX_LENGHT_FILE_NAME=${#file}
	fi
done
FILES_OK=0
FILES_TOT=0
#display results
if [ "${OPT_RESULT}" = "1" ]; then
for file in ${FILES[@]}; do
	if [[ "$(norminette ${file} | tail -n1)" == *"Norme: ${file}"* ]]; then 
	((FILES_OK=FILES_OK+1))
	((FILES_TOT=FILES_TOT+1))
	printf " ${CYAN}${file} ${GREEN}\033[${MAX_LENGHT_FILE_NAME}G\xe2\x9c\x85\n"
	else
	((FILES_TOT=FILES_TOT+1))
	printf " ${CYAN}${file}  ${RED}\033[${MAX_LENGHT_FILE_NAME}G\xe2\x9d\x8c\n"
	printf " ${WHITE}$(norminette ${file} | grep "Error" | cut -d " " -f2-)\n"
	fi
done
fi
#
##Unit test
# printf "\n ${FILES_OK}/${FILES_TOT}\n"
# if [[ "$(norminette ft_atoi.c | tail -n1)" == *"Norme: ./ft_atoi.c"* ]]; then 
# ((FILES_OK=FILES_OK+1))
# ((FILES_TOT=FILES_TOT+1))
# printf " ft_atoi.c  ${GREEN}\033[${MAX_LENGHT_FILE_NAME}G\xe2\x9c\x85\n"
# else
# ((FILES_TOT=FILES_TOT+1))
# printf " ft_atoi.c  ${RED}\033[${MAX_LENGHT_FILE_NAME}G\xe2\x9d\x8c\n"
# printf " $(norminette ft_atoi.c | grep "Error" | cut -d " " -f2-)\n"
# fi
# printf "  ${DEFAULT}${FILES_OK}/${FILES_TOT}\n"