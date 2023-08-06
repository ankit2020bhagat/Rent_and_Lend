ReantLend Contract
The ReantLend contract is a decentralized application that allows property owners to add their properties for rent and customers to book these properties. It is built on the Ethereum blockchain and utilizes the OpenZeppelin library for access control and counter functionalities.

Features
Property owners can add their properties to the platform with details such as property description and price per day.
Customers can book properties for a specific duration by paying the required booking amount.
Property owners can update property details and price per day for existing properties.
Customers can cancel their bookings, and the remaining balance is refunded to their address.
The contract automatically transfers 5% of the booking amount to the contract owner as a service fee.
The contract supports delisting properties from the platform by the property owner.
Property availability can be checked based on whether they are booked or available for rent.
Smart Contract Functions
The contract provides the following functions:

addPropety(string memory propertDetails, uint \_peicePerDay) public: Add a new property to the platform.
BookyourProperty(uint propertyId, uint duration) public payable: Book a property by a customer.
updatePropertyDetailes(uint propertyId, string memory \_propertyDetails, uint \_pricePerDay) public: Update the details and price per day of a property.
cancelBooking(address bookingId) public: Cancel a booking made by a customer.
transfer_money_To_propertyOwner() external: Transfer money to the property owner for completed bookings.
delistProperty(uint propertyId) public: Delist a property from the platform by the property owner.
checkAndreturn() public view returns (uint): Check and return the number of completed bookings.
get_List_of_all_Property() external view returns (PropertyDetails[] memory, uint): Get the list of all properties added to the platform.
get_list_of_rented_property() external view returns (PropertyDetails[] memory, uint): Get the list of rented properties.
property_available_for_rent() external view returns (PropertyDetails[] memory, uint): Get the list of properties available for rent.
setCounterAddress(address \_counter) external onlyOwner: Set the counter address for transferring money to the property owner.
Error Messages
The contract uses custom error messages to handle specific exceptions:

onlyowner(): Only the contract owner can call this function.
checkStatus(): The property is already booked.
insufficientBalance(): The customer doesn't have enough ether to book the property.
failedToTrnasfer(): Failed to transfer the balance to the property owner.
onlyCustomer(): Only the customer can call this function.
License
This contract is licensed under the MIT License. Please refer to the LICENSE file for more details.

Note
This contract is provided for educational and demonstration purposes only. Use it at your own risk and do not use it in a production environment without proper security auditing.
