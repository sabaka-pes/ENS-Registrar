# ENS-Registrar
This is a contract for the ENS domain registrar. This smart contract contains:
- Domain registration function. Bind any string value to the address. The fee for calling the registration function depends on the registration period. The function checks whether the domain is free. The domain is considered free if it has no records or if the registration period has expired;
- Setters for setting the domain price for the year and the domain renewal price coefficient. These setters can only be called by the contract owner;
- Domain renewal function. Renewal price = purchase price * coefficient. The function checks whether the domain currently belongs to the sender of the transaction;
- Function for obtaining the address of the domain owner;
- Function for withdrawing all received money (available only to the contract owner).
