#!/usr/bin/python3

from configparser import ConfigParser, RawConfigParser, UNNAMED_SECTION
from os import environ, makedirs, path, getcwd, getlogin, geteuid, getegid


this_dir =  path.dirname(path.realpath(__file__))
home_dir = path.expanduser("~")

calibre_service = ConfigParser()
# По умолчанию, ConfigParser переводит имена ключей в нижний регистр,
# используя встроенную функцию optionxform(), которая определена как:
# def optionxform(self, optionstr):
#   return optionstr.lower()
# Для предотвращения этого, переопределяем эту функцию на свою, которая
# принимает параметр optionstr и возвращает его без изменения.
calibre_service.optionxform = lambda optionstr: optionstr
calibre_service.read("calibre-service.sample")
calibre_service.set("Service", "User", str(geteuid()))
calibre_service.set("Service", "Group", str(getegid()))
for envvar in ["ExecStart", "EnvironmentFile", "WorkingDirectory"]:
    calibre_service.set("Service", envvar,
        path.join(this_dir, calibre_service.get("Service", envvar))
    )
with open("calibre-server.service", "w") as calibre_service.file:
    calibre_service.write(calibre_service.file,
        space_around_delimiters=False
    )

calibre_config = ConfigParser(allow_unnamed_section=True)
calibre_config.optionxform = lambda optionstr: optionstr
calibre_config.read("calibre-config.sample")
for envvar in ["LIBS_LOCAL_DIR", "CACHE_DIR", "CONFIG_DIR"]:
    calibre_config.set(UNNAMED_SECTION, envvar,
        path.join(home_dir, calibre_config.get(UNNAMED_SECTION, envvar))
    )
with open("calibre.config", "w") as calibre_config.file:
    calibre_config.write(calibre_config.file,
        space_around_delimiters=False
    )

exit(0)
