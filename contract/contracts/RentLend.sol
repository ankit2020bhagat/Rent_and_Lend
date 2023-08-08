// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
pragma solidity 0.8.19;

/**
 * @title ReantLend Contract
 * @dev This contract allows property owners to add their properties for rent and customers to book these properties.
 */
contract RentLend is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;
    Counters.Counter public IdtoBooking;

    /**
     * @dev Structure to store property details.
     */

    struct PropertyDetails {
        address propertyOwner;
        string details;
        bool isBooked;
        uint PricePerDay;
    }

    /**
     * @dev Structure to store booking details.
     */
    struct BookingDetails {
        uint propertyId;
        address customerAddress;
        uint duration;
        uint startTimeStamp;
        uint endTimeStamp;
        uint bookingAmount;
        mapping(address => uint) Balance;
    }
    address counterAddress;

    /// only owner can call this function
    error onlyowner();

    ///property is booked
    error BookedProperty();

    ///not having enough ether
    error insufficientBalance();

    ///failed to send balance
    error failedToTrnasfer();

    ///only customer can call this function
    error onlyCustomer();

    event addProperty(
        address propertyOwner,
        string details,
        bool isBooked,
        uint PricePerDay
    );

    event bookProperty(
        uint propertyId,
        address customerAddress,
        uint duration,
        uint startTimeStamp,
        uint endTimeStamp,
        uint amount,
        uint Balance
    );

    mapping(address => BookingDetails) public bookingdetails;
    mapping(uint => PropertyDetails) public PropertyDetailsId;
    mapping(uint => address) idToBookingAddress;

    /**
     * @dev Modifier to check if the property is booked.
     * @param propertyId The ID of the property to check.
     */
    modifier isBooked(uint propertyId) {
        PropertyDetails memory property = PropertyDetailsId[propertyId];
        if (property.isBooked) {
            revert BookedProperty();
        }
        _;
    }

    /**
     * @dev Modifier to check if the caller is the property owner.
     * @param propertyId The ID of the property to check ownership for.
     */
    modifier OnlyOwner(uint propertyId) {
        PropertyDetails memory property = PropertyDetailsId[propertyId];
        if (property.propertyOwner != msg.sender) {
            revert onlyowner();
        }
        _;
    }

    /**
     * @dev Modifier to check if the caller is the customer.
     * @param customerAddress The address of the customer to check.
     */
    modifier OnlyCustomer(address customerAddress) {
        BookingDetails storage _bookingdetails = bookingdetails[
            customerAddress
        ];
        if (_bookingdetails.customerAddress != customerAddress) {
            revert onlyCustomer();
        }
        _;
    }

    /**
     * @dev Add a new property to the platform.
     * @param propertDetails Details of the property.
     * @param _peicePerDay The price per day for renting the property.
     */
    function addPropety(
        string memory propertDetails,
        uint _peicePerDay
    ) public {
        _tokenIdCounter.increment();
        uint count = _tokenIdCounter.current();
        PropertyDetails storage addnewProPerty = PropertyDetailsId[count];
        addnewProPerty.propertyOwner = msg.sender;
        addnewProPerty.details = propertDetails;
        addnewProPerty.isBooked = false;
        addnewProPerty.PricePerDay = _peicePerDay;

        emit addProperty(
            addnewProPerty.propertyOwner,
            addnewProPerty.details,
            addnewProPerty.isBooked,
            addnewProPerty.PricePerDay
        );
    }

    /**
     * @dev Book a property by a customer.
     * @param propertyId The ID of the property to book.
     * @param duration The duration (in days) for which to book the property.
     */
    function BookyourProperty(
        uint propertyId,
        uint duration
    ) public payable isBooked(propertyId) {
        IdtoBooking.increment();
        uint count = IdtoBooking.current();
        PropertyDetails storage property = PropertyDetailsId[propertyId];
        if (msg.value < property.PricePerDay * duration) {
            revert insufficientBalance();
        }
        property.isBooked = true;

        BookingDetails storage _bookingdetails = bookingdetails[msg.sender];

        _bookingdetails.propertyId = propertyId;
        _bookingdetails.customerAddress = msg.sender;
        _bookingdetails.duration = duration;
        _bookingdetails.startTimeStamp = block.timestamp;
        _bookingdetails.endTimeStamp = block.timestamp + (duration * 24 hours);
        idToBookingAddress[count] = msg.sender;

        uint amount = (msg.value * 5) / 100;
        _bookingdetails.bookingAmount = (msg.value * 95) / 100;
        _bookingdetails.Balance[
            PropertyDetailsId[propertyId].propertyOwner
        ] = _bookingdetails.bookingAmount;
        uint Balance = _bookingdetails.Balance[
            PropertyDetailsId[propertyId].propertyOwner
        ];
        (bool success, ) = owner().call{value: amount}("");
        if (!success) {
            revert failedToTrnasfer();
        }

        emit bookProperty(
            _bookingdetails.propertyId,
            _bookingdetails.customerAddress,
            _bookingdetails.duration,
            _bookingdetails.startTimeStamp,
            _bookingdetails.endTimeStamp,
            _bookingdetails.bookingAmount,
            Balance
        );
    }

    /**
     * @dev Update the details and price per day of a property.
     * @param propertyId The ID of the property to update.
     * @param _propertyDetails The new details of the property.
     * @param _pricePerDay The new price per day for the property.
     */
    function updatePropertyDetailes(
        uint propertyId,
        string memory _propertyDetails,
        uint _pricePerDay
    ) public OnlyOwner(propertyId) isBooked(propertyId) {
        PropertyDetails storage updateproperty = PropertyDetailsId[propertyId];

        updateproperty.details = _propertyDetails;

        updateproperty.PricePerDay = _pricePerDay;
    }

    /**
     * @dev Cancel a booking made by a customer.
     * @param bookingId The booking ID to cancel.
     */
    function cancelBooking(address bookingId) public OnlyCustomer(bookingId) {
        BookingDetails storage _bookingdetails = bookingdetails[bookingId];
        PropertyDetails memory _propertyDetails = PropertyDetailsId[
            _bookingdetails.propertyId
        ];
        uint dutationleft = _bookingdetails.endTimeStamp -
            _bookingdetails.startTimeStamp;
        uint amountRemain = _bookingdetails.bookingAmount -
            dutationleft *
            _propertyDetails.PricePerDay;
        (bool success, ) = _bookingdetails.customerAddress.call{
            value: amountRemain
        }("");
        if (!success) {
            revert failedToTrnasfer();
        }
        delete bookingdetails[bookingId];
    }

    /**
     * @dev Transfer money to the property owner for completed bookings.
     */
    function transfer_money_To_propertyOwner() external {
        if (msg.sender != counterAddress) {
            revert();
        }
        uint count = IdtoBooking.current();
        uint currentIndex = 0;

        for (uint i = 0; i < count; i++) {
            currentIndex = 1 + i;
            address bookingAddress = idToBookingAddress[currentIndex];
            BookingDetails storage _bookingDetails = bookingdetails[
                bookingAddress
            ];
            if (block.timestamp > _bookingDetails.endTimeStamp) {
                //    _bookingDetails.isBooked = false;

                PropertyDetails memory _Propertydetails = PropertyDetailsId[
                    _bookingDetails.propertyId
                ];
                _Propertydetails.isBooked = false;
                address propertyOwner = _Propertydetails.propertyOwner;
                uint amount = _bookingDetails.Balance[propertyOwner];
                (bool success, ) = propertyOwner.call{value: amount}("");
                if (!success) {
                    revert failedToTrnasfer();
                }
                _bookingDetails.Balance[propertyOwner] = 0;
            }
        }
    }

    /**
     * @dev Delist a property from the platform by the property owner.
     * @param propertyId The ID of the property to delist.
     */
    function delistProperty(uint propertyId) public OnlyOwner(propertyId) {
        delete PropertyDetailsId[propertyId];
    }

    /**
     * @dev Check and return the number of completed bookings.
     * @return The number of completed bookings.
     */
    function checkAndreturn() public view returns (uint) {
        uint count = IdtoBooking.current();
        uint currentIndex = 0;
        uint currentId = 0;
        for (uint i = 0; i < count; i++) {
            currentIndex = 1 + i;
            address bookingAddress = idToBookingAddress[currentIndex];
            BookingDetails storage bookingDetails = bookingdetails[
                bookingAddress
            ];
            if (block.timestamp > bookingDetails.endTimeStamp) {
                currentId++;
            }
        }
        return currentId;
    }

    /**
     * @dev Get the list of all properties added to the platform.
     * @return An array containing the property details and the number of properties.
     */
    function get_List_of_all_Property()
        external
        view
        returns (PropertyDetails[] memory, uint)
    {
        uint count = _tokenIdCounter.current();
        uint currentIndex = 0;
        uint currentId = 0;
        PropertyDetails[] memory property = new PropertyDetails[](count);
        for (uint i = 0; i < property.length; i++) {
            currentIndex = i + 1;
            PropertyDetails storage propertyList = PropertyDetailsId[
                currentIndex
            ];
            property[currentId] = propertyList;
            currentId += 1;
        }
        return (property, property.length);
    }

    /**
     * @dev Get the list of rented properties.
     * @return An array containing the rented property details and the number of rented properties.
     */
    function get_list_of_rented_property()
        external
        view
        returns (PropertyDetails[] memory, uint)
    {
        uint count = _tokenIdCounter.current();
        uint currentIndex = 0;
        uint currentId = 0;
        for (uint i = 0; i < count; i++) {
            currentIndex = i + 1;
            if (PropertyDetailsId[currentIndex].isBooked) {
                currentId++;
            }
        }
        PropertyDetails[] memory property = new PropertyDetails[](currentId);
        currentIndex = 0;
        currentId = 0;
        for (uint i = 0; i < count; i++) {
            currentIndex = i + 1;
            PropertyDetails storage propertyList = PropertyDetailsId[
                currentIndex
            ];
            if (propertyList.isBooked) {
                property[currentId] = propertyList;
                currentId++;
            }
        }
        return (property, property.length);
    }

    /**
     * @dev Get the list of properties available for rent.
     * @return An array containing the available property details and the number of available properties.
     */
    function property_available_for_rent()
        external
        view
        returns (PropertyDetails[] memory, uint)
    {
        uint count = _tokenIdCounter.current();
        uint currentIndex = 0;
        uint currentId = 0;
        for (uint i = 0; i < count; i++) {
            currentIndex = i + 1;
            if (!PropertyDetailsId[currentIndex].isBooked) {
                currentId++;
            }
        }
        PropertyDetails[] memory property = new PropertyDetails[](currentId);
        currentIndex = 0;
        currentId = 0;
        for (uint i = 0; i < count; i++) {
            currentIndex = i + 1;
            PropertyDetails storage propertyList = PropertyDetailsId[
                currentIndex
            ];
            if (!propertyList.isBooked) {
                property[currentId] = propertyList;
                currentId++;
            }
        }
        return (property, property.length);
    }

    /**
     * @dev Set the counter address for transferring money to the property owner.
     * @param _counter The address to set as the counter address.
     */
    function setCounterAddress(address _counter) external onlyOwner {
        counterAddress = _counter;
    }
}
