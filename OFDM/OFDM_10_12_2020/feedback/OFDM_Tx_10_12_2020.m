connectedRadios = findsdru('30FD815');
if strncmp(connectedRadios(1).Status, 'Success', 7)
  radioFound = true;
  switch connectedRadios(1).Platform
    case {'B200','B210'}
      address = connectedRadios(1).SerialNum;
      platform = connectedRadios(1).Platform;
    case {'N200/N210/USRP2'}
      address = connectedRadios(1).IPAddress;
      platform = 'N200/N210/USRP2';
    case {'X300','X310'}
      address = connectedRadios(1).IPAddress;
      platform = connectedRadios(1).Platform;
  end
else
  radioFound = false;
  address = '192.168.10.2';
  platform = 'N200/N210/USRP2';
end

load('tx_data_oversampled4.mat');


WiFiFreqList = [2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472 2484];

Tx.MasterClockRate = 60e6;  %Hz
Tx.Fs = 1e6; % sps
Tx.USRPInterpolationFactor = Tx.MasterClockRate/Tx.Fs;
Tx.USRPGain = 21; % dB max 89.8dB
Tx.USRPTransportDataType      = 'int16';
Tx.USRPEnableBurstMode = false;

Tx.USRPCenterFrequency = WiFiFreqList(6)*1e6; %Hz

% signals are between -1 and 1 (real and imag parts)
% Rx.Gain=76 ; Tx.Gain=21; Loss=10dB; Tx and Rx scaled to max

radio = comm.SDRuTransmitter( ...
      'Platform',             platform, ...
      'SerialNum',            address, ...
      'MasterClockRate',      Tx.MasterClockRate, ...
      'CenterFrequency',      Tx.USRPCenterFrequency, ...
      'Gain',                 Tx.USRPGain,...
      'InterpolationFactor',  Tx.USRPInterpolationFactor, ...
      'TransportDataType',    Tx.USRPTransportDataType, ...
      'EnableBurstMode',      Tx.USRPEnableBurstMode);

% Check for the status of the USRP(R) radio

Tx.data= [zeros(length(data_to_send),1); data_to_send; zeros(length(data_to_send),1)];

if radioFound
    for iFrame = 1: 1000000
        step(radio, Tx.data); % transmit to USRP(R) radio
        disp(iFrame)
    end
else
    warning(message('no radio found'))
end

release(radio);

  