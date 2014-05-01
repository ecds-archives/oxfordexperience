#!/usr/bin/env python
import os
import sys

from django.core.management import execute_manager
try:
    import settings
except ImportError:
    import sys
    sys.stderr.write("Error: Can't find the file 'settings.py' in the directory containing %r. It appears you've customized things.\nYou'll have to run django-admin.py, passing it your settings module.\n(If the file settings.py does indeed exist, it's causing an ImportError somehow.)\n" % __file__)
    sys.exit(1)

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'test':
        # load test settings if necessary
        import testsettings as settings

    execute_manager(settings)


#if __name__ == "__main__":
#os.environ.setdefault("DJANGO_SETTINGS_MODULE", "oxfordexperience.settings")

#from django.core.management import execute_from_command_line

#execute_from_command_line(sys.argv)
