PROJECT_NAME := calibre

.PHONY: clean config deinstall install purge reinstall test

.ONESHELL:

CONFIG_FILE = calibre-server.config
-include ${CONFIG_FILE}
CALIBRE_CONFIG_DIR ?= ${HOME}/.config/calibre


config: test
	@
	echo -n "Конфигурирование сервера ... "
	python3 calibre-server-config.py || exit 10
	echo "OK!"
	echo -n "Установка файлов ... "
	install --mode=0755 -D calibre-server-sh.template \
	    "${CALIBRE_CONFIG_DIR}/calibre-server.sh"
	install --mode=0644 -Dt "${CALIBRE_CONFIG_DIR}" calibre-server.config \
	    calibre-server.service
	echo "OK!"
	echo "========== ${CONFIG_FILE} =========="
	cat  ${CONFIG_FILE}
	echo "Для установки сервера используйте команду 'sudo make install'"

CALIBRE_SERVER_SERVICE = $(notdir ${CALIBRE_SERVER_SERVICE_FILE})

install: ${CALIBRE_SERVER_CONFIG_FILE} ${CALIBRE_SERVER_SERVICE_FILE}
	@
	$(info Установка и запуск сервера Calibre...)
	if [ ${USER} != "root" ]; then
		echo "Нужны права суперпользователя!.."
		exit 10
	fi
	systemctl daemon-reload
	echo -n "Включение и рестарт сервера ... "
	systemctl enable ${CALIBRE_SERVER_SERVICE_FILE} || exit 10
	systemctl restart ${CALIBRE_SERVER_SERVICE} || exit 10
	echo "OK!"


deinstall:
	@
	$(info Удаление сервера...)
	if [ ${USER} != "root" ]; then
		echo "Необходимы права суперпользователя!.."
		exit 10
	fi
	systemctl stop calibre-server.service
	systemctl disable calibre-server.service
	systemctl daemon-reload


.SILENT: test

REQUIRED = systemctl calibre-server python3
PYTHON_VERSION_FULL := $(wordlist 2,4,$(subst ., ,$(shell python3 -V 2>&1)))
PYTHON_VERSION_MAJOR := $(word 1,${PYTHON_VERSION_FULL})
PYTHON_VERSION_MINOR := $(word 2,${PYTHON_VERSION_FULL})
PYTHON_VERSION_PATCH := $(word 3,${PYTHON_VERSION_FULL})

test:
	$(foreach EXEC,$(REQUIRED),
		$(if $(shell which $(EXEC) 2> /dev/null),
			$(info Проверка наличия $(EXEC) ... OK),
			$(error Отсутствует $(EXEC). Установите!. ... FAIL!)
		)
	)

	if [ ${PYTHON_VERSION_MINOR} -lt 13 ]; then
		echo "Требуется Python версии не ниже 3.13 ... FAIL!"
		exit 10
	fi
	echo "Python 3.$(PYTHON_VERSION_MINOR).$(PYTHON_VERSION_PATCH) ... OK"


deploy:
	@
	$(info Обновление библиотеки на сервере...)
#	ssh $(REMOTE_HOST) sudo systemctl stop calibre-server.service
	rsync \
		--archive --delete-after --recursive --update --progress --verbose \
		--filter="- .calnotes" --filter="- .caltrash" \
		"$(LIBS_LOCAL_DIR)" "$(SERVER):$(LIBS_SERVER_DIR)"
#	ssh $(REMOTE_HOST) sudo systemctl restart calibre-server.service
