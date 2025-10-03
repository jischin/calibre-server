PROJECT_NAME := calibre


SRC_FILES := $(wildcard ./calibre-server.*)

# Список требуемых для работы проекта утилит.
REQUIRED = rsync install calibre-server

.PHONY: deploy test clean install reinstall purge config server-config

.ONESHELL:


deploy:
	@
	$(info Обновление библиотеки на сервере...)
#	ssh $(REMOTE_HOST) sudo systemctl stop calibre-server.service
	rsync \
		--archive --delete-after --recursive --update --progress --verbose \
		--filter="- .calnotes" --filter="- .caltrash" \
		"$(CALIBRE_LOCAL)" "$(CALIBRE_REMOTE)"
#	ssh $(REMOTE_HOST) sudo systemctl restart calibre-server.service


### Действия выполняются на сервере.

server-config: calibre-server.service calibre-service.sample calibre-config.py calibre-config.sample
	$(info Конфигурирование сервера...)
	./calibre-config.py


server-install:
	@
	$(info Установка и запуск сервера...)
	if [[ $$USER != "root" ]]; then
		echo "Необходимы права суперпользователя!.."
		exit 10
	fi
	# ln -sft /etc/systemd/system "$(CURDIR)/calibre-server.service"
	systemctl daemon-reload
	systemctl enable $(CURDIR)/calibre-server.service
	systemctl restart calibre-server.service

server-deinstall:
	@
	$(info Удаление сервера...)
	if [[ $$USER != "root" ]]; then
		echo "Необходимы права суперпользователя!.."
		exit 10
	fi
	systemctl stop calibre-server.service
	systemctl disable calibre-server.service
	# rm /etc/systemd/system/calibre-server.service
	systemctl daemon-reload



test:
	$(foreach EXEC,$(REQUIRED), \
		$(if $(shell which $(EXEC) 2> /dev/null), \
			$(info Проверка наличия $(EXEC) ... OK), \
			$(error Отсутствует $(EXEC). Установите!. ... FAIL!)))

# минус в начале команды позволяет игнорировать возможную ошибку и не
# прерывать из-за неё скрипт.
