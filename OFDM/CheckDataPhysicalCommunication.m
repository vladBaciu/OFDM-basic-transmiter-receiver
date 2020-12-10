
clc
close all
clear variables

data = load('tx_data_test_spectrum.mat');
Tx_data = data.save_data_tx;
%Rx_data = data.Rx_OFDM_19_11_2020;

data_fs_1MHz = load('Rx_OFDM_19_11_2020_fs_1Mhz.mat');
Rx_data_1MHz = data_fs_1MHz.Rx_OFDM_19_11_2020_fs_1Mhz;

fs = 20e6;
x = -fs/2:fs/128:fs/2-fs/128;


% Spectrum transmitted data
% figure
plot(x, abs(fftshift(fft(Tx_data(10+[1:128])))), 'x')
title('FFT one transmit symbol')
xlabel('Frequency [Hz]')
ylabel('Amplitude')

hold on 

% Spectrum received data
tmp = Rx_data_1MHz(2575+[1:1370]);

% figure
plot(x , abs(fftshift(fft(tmp(9+[1:128])))), 'x')
title('FFT one received symbol')
xlabel('Frequency [Hz]')
ylabel('Amplitude')


% Spectrum received data 1MHz
fs = 1e6;
% figure
for k=9 
    tmp=Rx_data_1MHz(2660+k+[1:128]);
    plot(x, abs(fftshift(fft(tmp))),'xg');
    xlabel('Frequency [Hz]')
    ylabel('Amplitude')
%     pause;
end

legend('Spectrum transmitted data','Spectrum received data','Spectrum received data')
hold off