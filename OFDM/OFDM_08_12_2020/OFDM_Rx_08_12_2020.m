%    release(radio)

connectedRadios = findsdru('30FD80C');
if strncmp(connectedRadios(1).Status, 'Success', 7)
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

WiFiFreqList = [2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472 2484];

Rx.MasterClockRate = 60e6;  %Hz
Rx.Fs = 1e6; % sps
Rx.USRPDecimationFactor = Rx.MasterClockRate/Rx.Fs;
% Rx.USRPCenterFrequency = 2.4e9; %Hz
Rx.USRPGain = 70; % dB max 76dB
Rx.USRPFrameLength = 375000;
Rx.USRPTransportDataType = 'double';

Rx.USRPCenterFrequency = WiFiFreqList(6)*1e6; %Hz
radio = comm.SDRuReceiver(...  
                'Platform',             platform, ...
                'SerialNum',            address, ...
                'MasterClockRate',      Rx.MasterClockRate, ...
                'CenterFrequency',      Rx.USRPCenterFrequency, ...
                'Gain',                 Rx.USRPGain, ...
                'DecimationFactor',     Rx.USRPDecimationFactor, ...
                'SamplesPerFrame',       Rx.USRPFrameLength, ...
                'OutputDataType',       Rx.USRPTransportDataType);

% Initialize variables
len = uint32(0);
rcvdSignal = complex(zeros(Rx.USRPFrameLength,1));
currentTime = 0; 
maxIFrame = 1;
Rx.allRcvdSignals=zeros(Rx.USRPFrameLength,maxIFrame);
disp('Press any key')
 pause

for iFrame=1:maxIFrame
    % Keep accessing the SDRu System object output until it is valid

%     Rx.USRPCenterFrequency = WiFiFreqList(iFrame)*1e6; %Hz
%     radio = comm.SDRuReceiver(...
%                 'Platform',             platform, ...
%                 'SerialNum',            address, ...
%                 'MasterClockRate',      Rx.MasterClockRate, ...
%                 'CenterFrequency',      Rx.USRPCenterFrequency, ...
%                 'Gain',                 Rx.USRPGain, ...
%                 'DecimationFactor',     Rx.USRPDecimationFactor, ...
%                 'SamplesPerFrame',      Rx.USRPFrameLength, ...
%                 'OutputDataType',       Rx.USRPTransportDataType);

    while len <= 0
        [rcvdSignal, len, overrun] = radio();
    end
    if (overrun)
        warning("Overrun!!!")
    end
    Rx.allRcvdSignals(:,iFrame)=rcvdSignal;
    disp([iFrame len]);
    len=uint32(0);
    pause(1)
    plot(fftshift(20*log10(abs(fft(rcvdSignal)))),'b*')
    shg;
end


release(radio);

save rx_data_12_08_short_period rcvdSignal
% load('tx_data_12_08_lg_7500_8_50.mat');
% load('rx_data_12_08_lg_7500_11.mat')
% load('rx_data_12_08_s_7500_8_20.mat')
% load('rx_data_12_08_s_15000_8_20.mat')
% load('rx_data_12_08_s_15000_8_50.mat')
% load('rx_data_12_08_s_30000_8_50.mat')
% load('rx_data_12_08_short_period.mat')



  