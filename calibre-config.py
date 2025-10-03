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
calibre_service.set("Service", "WorkingDirectory", this_dir)
calibre_service.set("Service", "ExecStart",
    path.join(this_dir, calibre_service.get("Service", "ExecStart"))
)
calibre_service.set("Service", "EnvironmentFile",
    path.join(this_dir, calibre_service.get("Service", "EnvironmentFile"))
)
with open("calibre-server.service", "w") as calibre_service.file:
    calibre_service.write(calibre_service.file,
        space_around_delimiters=False
    )


calibre_config = ConfigParser(allow_unnamed_section=True)
calibre_config.optionxform = lambda optionstr: optionstr
calibre_config.read("calibre-config.sample")
calibre_config.set(UNNAMED_SECTION, "LIBS_LOCAL_DIR",
    path.join(home_dir, calibre_config.get(UNNAMED_SECTION, "LIBS_LOCAL_DIR"))
)
calibre_config.set(UNNAMED_SECTION, "CONFIG_DIR", this_dir)

with open("calibre.config", "w") as calibre_config.file:
    calibre_config.write(calibre_config.file,
        space_around_delimiters=False
    )

exit(0)
