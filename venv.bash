#!/bin/bash

# Workspace with scenario runner cloned and carla in /opt/tri/carla

NAME=streamlit

##############################################################################
# Configuration
##############################################################################

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VENV_DIR=${SRC_DIR}/.venv-${NAME}
PIP=pip3
PYTHON=python3

##############################################################################
# Colours
##############################################################################

BOLD="\e[1m"
CYAN="\e[36m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

padded_message () {
  line="........................................"
  printf "%s %s${2}\n" ${1} "${line:${#1}}"
}

pretty_header () {
  echo -e "${BOLD}${1}${RESET}"
}
pretty_print () {
  echo -e "${GREEN}${1}${RESET}"
}
pretty_warning () {
  echo -e "${YELLOW}${1}${RESET}"
}
pretty_error () {
  echo -e "${RED}${1}${RESET}"
}
 
#############################
# Checks
#############################

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && SOURCED=1
if [ -z "$SOURCED" ]; then
  pretty_error "This script needs to be sourced, i.e. source '. $0', not '$0'"
  exit 1
fi

#############################
# Sources
#############################

pretty_header "Sources"

if [ -d "streamlit_sandbox" ]; then
  # TODO: double check installed version
  pretty_print "  $(padded_message "streamlit_sandbox" "found [devel]")"
else
  git clone https://github.com/stonier/streamlit_sandbox.git streamlit_sandbox
  pretty_warning "  $(padded_message "streamlit_sandbox" "cloned [devel]")"
fi

#############################
# Virtual Environment Setup
#############################

pretty_header "Virtual Environment Configuration"

# Create the virtual environment
if [ -x ${VENV_DIR}/bin/${PIP} ]; then
    pretty_print "  $(padded_message "virtual_environment" "found [${VENV_DIR}]")"
else
    ${PYTHON} -m venv ${VENV_DIR}
    pretty_warning "  $(padded_message "virtual_environment" "created [${VENV_DIR}]")"
fi


# On entry
cat <<EOT > ${VENV_DIR}/bin/postactivate
#!/bin/bash

export FOO=foo

alias foo="echo 'foo'"carla-launch-server=${CARLA_ROOT}/CarlaUE4.sh
EOT

# On exit
cat <<EOT > ${VENV_DIR}/bin/postdeactivate
#!/bin/bash

unset FOO

unalias foo
EOT

if ! grep -Fq "postactivate" ${VENV_DIR}/bin/activate
then
  pretty_warning "  $(padded_message "postactivate" "added [${VENV_DIR}]")"
  echo "source ${VENV_DIR}/bin/postactivate" >> ${VENV_DIR}/bin/activate
else
  pretty_print "  $(padded_message "postactivate" "found [${VENV_DIR}]")"
fi

if ! grep -Fq "postdeactivate" ${VENV_DIR}/bin/activate
then
  pretty_warning "  $(padded_message "postdeactivate" "added [${VENV_DIR}]")"
   sed -i "s|unset -f deactivate|unset -f deactivate\n    source $VENV_DIR\/bin\/postdeactivate|" ${VENV_DIR}/bin/activate
else
  pretty_print "  $(padded_message "postdeactivate" "found [${VENV_DIR}]")"
fi

#############################
# Python Paths
#############################

pretty_header "Python Paths"

SITE_PACKAGES_DIR=$(${VENV_DIR}/bin/${PYTHON} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

# echo ${CARLA_ROOT}/PythonAPI > ${SITE_PACKAGES_DIR}/streamlit_sandbox.pth
#pretty_print "  $(padded_message "pythonpath" "added [${CARLA_ROOT}/PythonAPI]")"

#############################
# Virtual Environment
#############################

pretty_header "Virtual Environment"

source ${VENV_DIR}/bin/activate
if [ $? -eq 0 ]; then
  pretty_print "  $(padded_message "virtual_environment" "activated")"
else
  pretty_error "  $(padded_message "virtual environment" "failed")"
  return
fi

# cd ${SRC_DIR}/carla_tri_scenarios && ${PYTHON} setup.py develop > /dev/null
# if [ $? -eq 0 ]; then
#   pretty_print "  $(padded_message "carla_tri_scenarios" "activated")"
# else
#   cd ${SRC_DIR} && deactivate
#   pretty_error "  $(padded_message "carla_tri_scenarios" "failed")"
#   return
# fi
# cd ${SRC_DIR}

#############################
# Pypi Dependencies
#############################

pretty_header "PyPi Dependencies"

${PIP} install wheel
${PIP} install setuptools==47.3.1
${PIP} install distro

${PIP} install -r streamlit_sandbox/requirements.txt

#############################
# Summary
#############################

VENV_PYTHON_PATH=$(${VENV_DIR}/bin/${PYTHON} -c "import sys; print(sys.path)")

echo -e ""
echo -e "${BOLD}------------------------------------------------------------------------${RESET}"
echo -e "${BOLD}              Streamlit Sandbox${RESET}"
echo -e "${BOLD}------------------------------------------------------------------------${RESET}"
echo -e ""
echo -e "${CYAN}PYTHON PATH: ${YELLOW}${VENV_PYTHON_PATH}${RESET}"
echo -e "${CYAN}ALIASES${RESET}"
echo -e "${CYAN} - ${YELLOW}foo${RESET}"
echo -e ""
echo -e "${BOLD}------------------------------------------------------------------------${RESET}"
echo -e ""
echo -e "${GREEN}Leave the virtual environment with 'deactivate'${RESET}"
echo -e ""
echo -e "${GREEN}I'm grooty, you should be too.${RESET}"
echo -e ""
