+++
title = "AT Commands Reference"
date = "2016-11-26"
tags = ["standards", "communications"]
+++

The Hayes command set, also called the AT command set, is a specific command
language originally developed by Dennis Hayes[1] for the Hayes Smartmodem 300
baud modem in 1981.

The command set consists of a series of short text strings which can be combined
to produce commands for operations such as dialing, hanging up, and changing the
parameters of the connection. The vast majority of dial-up modems use the Hayes
command set in numerous variations.

Every Hayes command starts with the "AT" characters.

The Hayes command set can subdivide into four groups:

- Basic command set.  A capital character followed by a digit.
- Extended command set. An "&" and a capital character followed by a digit.
- Proprietary command set. Usually starting either with a backslash ("\") or with a percent sign ("%").
- Register commands. S<r>=<n> where <r> is the number of the register to be changed, and <n> is the new value that is assigned.

## Conventions

    > AT<cmd>[?]
    [response]

- <cmd> : actual AT command.
- <response> : modem response (optional).
- ? : for some commands the question mark is used to get the current value(s).


## Generic Commands

### ATZ - Reset to Default Configuration

Set the modem to default values.

    > ATZ

### AT&F - Reset to Factory-Defined Configuration

Set modem parameters to the factory defalts.

    > AT&F

### ATE - Command Echo

Determines whether or not the modem echoes characters received from the DTE during command state.

    > ATE?
    E: <value>

Enable/Disable echo

    > ATE<value>

value:
- 0 : characters are not echoed
- 1 : characters are echoed

###  AT&V - Read the Configuration

Displays the stored and active modem profile settings

    > AT&V
    <settings>

###  AT+ICF - DTE to DCE Character Framing

This command determines the local serial port start-stop (asynchronous) character framing used by the DCE.

Get possible values

    > AT+ICF=?

Get current values

    > AT+ICF?

Set new values

    > AT+ICF=[<format>[,<parity>]]

format:
- 0 : auto detect
- 1 : 8 data bits, 0 parity bit, 2 stop bits (8N2)
- 3 : 8 data bits, 0 parity bit, 1 stop bit (8N1)
- 4 : 7 data bits, 0 parity bit, 2 stop bits (7N2)
- 5 : 7 data bits, 1 parity bit, 1 stop bit (7P1)

parity:
- 0 : odd
- 1 : even
- 2 : space (0)


### AT+IPR - Boud Rate

Set the data rate on the GSM Data Module's serial interface

    > AT+IPR=<rate>

Default rate is 9600


###  AT+IFC - Flow Control

This command controls the operation of local flow control between the DTE and DCE. Used when the modem is in Data Mode.

    > AT+ICF=[<dce2dte>[,<dte2dce>]]

dce2dte/dte2dce:
- 0 : none
- 1 : XON/XOFF
- 2 : line 133


## Mobile Equipment Control

### AT+CFUN - Set Phone Functionality

List of supported functionalities

    > AT+CFUN=?
    CFUN: (list of supported <fun>s)

Get current functionalities

    > AT+CFUN?
    CFUN: <fun>

Set new functinalities

    > AT+CFUN=[<fun>]

fun:
- 0 : set minimum functionalities
- 1 : set full functionality

### AT+CPIN - Enter PIN

Used to query and enter a password which is necessary before the modem will operate.

Get current protection types

    > AT+CPIN?
    +CPIN: <code>
    
code:
- READY : no password required
- SIM PIN : pin code needs to be entered
- SIM PUK : puk code needs to be entered

Enter/Change PIN code

    > AT+CPIN=<pin>[,<newpin>]
    +CPIN: SIM PIN

#### PIN disable

Using the "Facility Lock" command.

    > AT+CLCK="SC",0,"1234"


## Generic DCE Control Commands

### +++ - Changes from Online Data mode to Online Command mode

    > <wait-for-0.5-second>+++<wait-for-0.5-second>

### ATO - Back to data mode (after +++)

    > ATO

### ATH - Hang-up

Instructs the modem to disconnect from the line, terminating any call in progress.

    > ATH

Used by the application to disconnect the remote use

### ATD - Dial Command

To start a call to a destination number.

    > ATD<number>
    <result>

Result:
- OK : command executed, no error
- CONNECT <text> : connection set up
- RING : ringing tone is present
- NO CARRIER : call failed to connect or disconnected
- ERROR : invalind command or too long
- BUSY : the called party is currently in another call
- NO ANSWER : connection failed up to time out

### AT+CREG - Network Registration

List of supported <n>s

    > AT+CREG=?
    +CREG: (list of supported <n>s)

    > AT+CREG?
    +CREG: <n>,<stat>

n:
- 0 : disable network registration unsolicited result code
- 1 : enable network registration unsolicited result code

stat:
- 0 : not registered operator to registered and not searching
- 1 : registered, home network
- 2 : not registered, currently searching a new operator to register with
- 3 : registration denied
- 4 : unknown
- 5 : registered, roaming

### AT+COPS - Operator Selection

Registers/displays network operators available

    > AT+COPS=?

    > AT+COPS?

    > AT+COPS=[<mode>[,<format>[,<oper>]]]

### AT+CBST - Bearer type selection

Selects the bearer service for mobile originated calls.

List available options

    > AT+CBST=?
    +CBST: (list of supported <speed>s),(list of supported <name>s),
           (listed of supported <ce>s)

Get current values

    > AT+CBST?
    +CBST: <speed>,<name>,<ce>

Set new values

    > AT+CBST=[<speed>[,<name>[,<ce>]]]

ce:
- 0 : transparent
- 1 : non-transparent

### Select message service

    AT+CSMS

0: SMS AT commands are compatible with GSM 07.05 Phase 2 version 4.7.0.
1: SMS AT commands are compatible with GSM 07.05 Phase 2 + version .

Response

    +CSMS: 1,1,1


### AT+CMGF - SMS Format

Controls the presentation format of shot messages, from the modem.

List supported modes

    > AT+CMGF=?
    +CMGF: (list of supported <mode>s)

Get current mode

    > AT+CMGF?
    +CMGF: <mode>

Set new mode

	> AT+CMGF=<mode>

mode: 
- 0 : PDU Mode
- 1 : Text Mode

### AT+CMGS - Send SMS

Send a short message from the modem to the network.

	> AT+CMGS=<number><CR><message><CTRL-Z>
    +CMGS: <mr>

### ATS0 - Automatic Answer

List of supported values

    > ATS0=?
    S0(list of supported <values>)

Get current value

    > ATS0?
    <value>

Set new value

    > ATS0=<value>

value:
- 0 : disable auto answer
- 1-255 : auto answer on the ring number specified
