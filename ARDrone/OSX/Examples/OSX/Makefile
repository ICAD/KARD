
.PHONY:

all:
	@$(MAKE) -C ../../ARDroneLib/Soft/Build USE_OSX=yes
	@$(MAKE) -C sdk_demo/Build USE_OSX=yes 
	@$(MAKE) -C Testbenches/multiconfiguration/Build USE_OSX=yes
	@$(MAKE) -C Testbenches/ftp_test/Build USE_OSX=yes

$(MAKECMDGOALS):
	@$(MAKE) -C ../../ARDroneLib/Soft/Build USE_OSX=yes $(MAKECMDGOALS)
	@$(MAKE) -C sdk_demo/Build USE_OSX=yes $(MAKECMDGOALS)
	@$(MAKE) -C Testbenches/multiconfiguration/Build USE_OSX=yes $(MAKECMDGOALS)
	@$(MAKE) -C Testbenches/ftp_test/Build USE_OSX=yes $(MAKECMDGOALS)



