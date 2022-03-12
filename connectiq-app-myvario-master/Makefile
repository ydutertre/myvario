## ConnectIQ resources
include Makefile.ciq


## Project resources
MY_PROJECT := MyVario
MY_JUNGLES := ./monkey.jungle
MY_RESOURCES := $(shell find -L resources* -name '*.xml')
MY_SOURCES := $(shell find -L source -name '*.mc')


## Help
.PHONY: help
help:
	@echo 'Targets:'
	@echo '  ciq-help    - display the build environment help'
	@echo '  help        - display this help message'
	@echo '  debug       - build the project (*.prg; including debug symbols)'
	@echo '  release     - build the project (*.prg; excluding debug symbols)'
	@echo '  iq          - package the project (*.iq)'
	@echo '  run-debug   - launch the project in the simulator (debug version)'
	@echo '  run-release - launch the project in the simulator (release version)'
	@echo '  fit-view    - view the FIT-file'
	@echo '  clean       - delete all build output'
.DEFAULT_GOAL := help


## Build

# debug
OUTPUT_DEBUG := ./bin/${MY_PROJECT}.debug.prg
${OUTPUT_DEBUG}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}
	mkdir -p bin
	${CIQ_MONKEYC} -w -l 3 \
	  -o $@ \
	  -d ${CIQ_DEVICE} \
	  -c ${CIQ_API} \
	  -y ${CIQ_DEVKEY} \
	  -f ${MY_JUNGLES}
debug: ${OUTPUT_DEBUG}

# release
OUTPUT_RELEASE := ./bin/${MY_PROJECT}.prg
${OUTPUT_RELEASE}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}
	mkdir -p bin
	${CIQ_MONKEYC} -w -l 3 -r \
	  -o $@ \
	  -d ${CIQ_DEVICE} \
	  -c ${CIQ_API} \
	  -y ${CIQ_DEVKEY} \
	  -f ${MY_JUNGLES}
release: ${OUTPUT_RELEASE}

# IQ
OUTPUT_IQ := ./bin/${MY_PROJECT}.iq
${OUTPUT_IQ}: ${MY_MANIFEST} ${MY_RESOURCES} ${MY_SOURCES} | ${CIQ_MONKEYC} ${CIQ_DEVKEY}
	mkdir -p bin
	${CIQ_MONKEYC} -e -w -r \
	  -o $@ \
	  -y ${CIQ_DEVKEY} \
	  -f ${MY_JUNGLES}
iq: ${OUTPUT_IQ}


## Simulator
.PHONY: run-debug
run-debug: ${OUTPUT_DEBUG} | ${CIQ_SIMULATOR} ${CIQ_MONKEYDO}
	${CIQ_SIMULATOR} & sleep 1
	${CIQ_MONKEYDO} ${OUTPUT_DEBUG} ${CIQ_DEVICE}

.PHONY: run-release
run-release: ${OUTPUT_RELEASE} | ${CIQ_SIMULATOR} ${CIQ_MONKEYDO}
	${CIQ_SIMULATOR} & sleep 1
	${CIQ_MONKEYDO} ${OUTPUT_RELEASE} ${CIQ_DEVICE}


## FIT-file viewer
.PHONY: fit-view
fit-view: ${OUTPUT_IQ} ${CIQ_FITFILE} | ${CIQ_MONKEYGRAPH}
	java -jar ${CIQ_MONKEYGRAPH}


## (Un-)Install

# mountpoint
${DESTDIR}/Garmin/Apps:
	$(error Garmin device not found; DESTDIR=${DESTDIR})

# install
.PHONY: install
install: ${OUTPUT_RELEASE} | ${DESTDIR}/Garmin/Apps
	@cp -v ${OUTPUT_RELEASE} ${DESTDIR}/Garmin/Apps/${MY_PROJECT}.prg

# uninstall
.PHONY: uninstall
uninstall: | ${DESTDIR}/Garmin/Apps
	@rm -fv ${DESTDIR}/Garmin/Apps/${MY_PROJECT}.prg \
	  ${DESTDIR}/Garmin/Apps/SETTINGS/${MY_PROJECT}.SET \
	  ${DESTDIR}/Garmin/Apps/DATA/${MY_PROJECT}.STR \
	  ${DESTDIR}/Garmin/Apps/DATA/${MY_PROJECT}.IDX \
	  ${DESTDIR}/Garmin/Apps/DATA/${MY_PROJECT}.DAT \
	  ${DESTDIR}/Garmin/Apps/LOGS/${MY_PROJECT}.TXT \
	  ${DESTDIR}/Garmin/Apps/LOGS/${MY_PROJECT}.BAK


## Clean
.PHONY: clean
clean:
	rm -rf bin
