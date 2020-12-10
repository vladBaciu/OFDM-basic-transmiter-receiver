function [signal_Tx_mult] = CHANNEL_multipath(out)
signal_Tx = reshape(out,1,[]); % Become a complete signal in the time domain, to be transmitted
mult_path_am = [1 0.2 0.1]; %  Multipath amplitude
mutt_path_time = [0 20 50]; % Multipath delay
windowed_Tx = zeros(size(signal_Tx));
path2 = 0.2*[zeros(1,20) signal_Tx(1:end-20) ];
path3 = 0.1*[zeros(1,50) signal_Tx(1:end-50) ];
signal_Tx_mult = signal_Tx + path2 + path3; % Multipath signal
% figure('menubar','none')
% subplot(2,1,1)
% plot(signal_Tx_mult)
% title('OFDM signal under multipath')
% xlabel('Time/samples')
% ylabel('Amplitude')
% subplot(2,1,2)
% plot(signal_Tx)
% title('OFDM signal under single path')
% xlabel('Time/samples')
% ylabel('Amplitude')