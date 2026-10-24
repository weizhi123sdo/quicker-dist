PS Flow 0.7.1 / bb80ed7529230b01

Main and companion action sources embed the same verified installer. Fresh computers install app build bb80ed7529230b01. Runtime and optional local backend deliberately reuse their immutable 0.7.0 pins.

Install.cmd starts the installer. Quicker users should update both shared actions to the 0.7.1 release. Existing user data is preserved during installation; full uninstall requires explicit confirmation.
