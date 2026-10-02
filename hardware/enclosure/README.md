# Enclosure

I am building an enclosure for an ESP32 on a proto board. It is an esp32 classic. I have two screw terminals on the board. A 2pin on the left corner connected to a panel-mounted barrel plug and a 3pin on the right corner connected to a JST SM LED connector that will be panel-mounted as well. On the opposite side of the enclosure is the Micro USB for the esp32. We need plenty of room for the wires to go from the peel-mount to then feed into the screw terminals. Below are dimensions. Help me design this thing. I’d also like to be able to do a test print on small parts like the proto board mounts to make sure they fit before printing the entire enclosure.

## Dimensions

* Barrel connector
  * 9.77mm barrel plug diameter
  * 2.02mm panel flange width
  * 13.7mm nut width
* JST SM
  * 7.47mm height
  * 10.47mm width
  * 8.11mm panel flange width
* Proto board ("5x7cm")
  * 68.68mm l
  * 48.70mm w
  * 44mm from inner hole to hole w
  * 63.75mm from inner hole to hole l
  * 2.34mm diameter of hole
* ESP32
  * mounted on proto board from columns D5 to D15 and rows H through 
  * hangs over 3.175mm past the bottom of the protoboard board, mount flush
  * Micro USB
    * 8.03mm width
    * 2.95mm height
    * doesn't hang much over the esp32 board


## v0

Things to fix:
- [x] The wiring is way too tight. Add l and w to the enclosure
- [ ] The protoboard w seems good as i can get both standoff screws in. however, the length is off. The product page says 5x7cm.
- [ ] Lid screws were a bit tough to get in. Increase the inner diameter a bit.
- [ ] JST has plenty of room. Could tighten. Or design a shim to add later
- [ ] Barrel connector nut cutout can be made a lot smaller
- [ ] Barrel connector hole can be made smaller
- [ ] Micro usb is too big and offset.
    - [ ] Move it down and 1 proto pin right
    - [ ] Move board back to panel mount the micro - 2/16" end gap
    - [ ] Make opening smaller. Connector is 3/16" x 7/16". however, if we panel mount we can fit the size of the micro