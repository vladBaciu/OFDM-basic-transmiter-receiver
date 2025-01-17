% function [] = real_world_rx_estimate(parameters, rx_buffer, pilot_interval_index)



tx_data_old = load('OFDM_15_12_2020/tx_data.mat')
tx_data_old = tx_data_old.save_data_tx;
% load Rx_OFDM_19_11_2020.mat 
% load tx_constellation.mat
% load Rx_OFDM_19_11_2020_fs_1Mhz.mat
rx_data = load('OFDM_17_12_2020/output/rx_data_downsampled4_B_1.mat');
rx_data = rx_data.rcvdSignal;
%out1 = Rx_OFDM_19_11_2020;
out1 = rx_data;

rx_data = load('OFDM_17_12_2020/output/rx_data_downsampled4_B_1.mat');
rx_data = rx_data.rcvdSignal(2400:3500);
tf_data = rx_data;

rx_constellations = OFDM_rx(parameters,out1,0);
tx_wihout_pilot = frequencyDomain_symbols;

tx_wihout_pilot(pilot_interval_index(1:end),:) = [];
tx_constellations = reshape(tx_wihout_pilot,[],1);

% COMMENT - Unfortunately the tx frequency symbols aren't available for the 
% rx_data_downsampled4_B to compute the BER. 
% template_frequencyDomain was created with this purpose for future use if
% necessary - save('template_frequencyDomain','tx_wihout_pilot');


% Error
% error = rx_constellations - tx_constellations;

% L^2 norm for error between rx and tx
% norm_error = norm(error);
% fprintf('norm error =%d\n',norm_error/length(error));
% if norm_error/length(error) < 0.2
%     disp('tx data = rx data');
% else
%     disp('tx data != rx data');
% end
% te = sum(abs(error));
% BER = te/length(rx_constellations)

t=1:1:length(out1);
t = t * sampling_period;
b=1:1:parameters.fft_size;
tf_t = 1:1:length(tf_data);
tf_t = tf_t * sampling_period;

figure
plot(tf_t,real(tf_data))
save('OFDM_12_01_2021/output/tf_response.mat','tf_data') 

tx_data_temp = 0;
tx_data_temp(1:length(tx_data_old)) = tx_data_old;
tx_data_temp(length(tx_data_old)+1:length(out1)) = 0;
figure
plot(t,real(out1))
hold on
% plot(t,real(tx_data_temp))
title('Time domain data')
xlabel('Time (s)')
ylabel('Amplitude')
legend('Rx signal')

figure
[r,lags] = xcorr(out1,tx_data_temp);
stem(lags,real(r))


figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(tx_constellations, 'o', 'color','red')
title('RX constellations')



%end