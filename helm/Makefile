.PHONY: build

install-test:
	@ echo "Installing test..."
	@ ./process.sh test install
	@ echo "Done."

uninstall-test:
	@ echo "Uninstalling test..."
	@ ./uninstall.sh test
	@ echo "Done."

delete-test:
	@ echo "Deleting test cluster"
	@ helm delete test-deployment
