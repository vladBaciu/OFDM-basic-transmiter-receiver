% function [] = real_world_rx_estimate(parameters, rx_buffer, pilot_interval_index)

tx_data_old = load('tx_data_old.mat')
tx_data_old = tx_data_old.save_data_tx;
load Rx_OFDM_19_11_2020.mat 
load tx_constellation.mat
load Rx_OFDM_19_11_2020_fs_1Mhz.mat

%out1 = Rx_OFDM_19_11_2020;
out1 = Rx_OFDM_19_11_2020(10000:13000);
rx_constellations = OFDM_rx(parameters,out1,0);
tx_wihout_pilot = frequencyDomain_symbols;
tx_wihout_pilot(pilot_interval_index(1:end),:) = [];
tx_constellations = reshape(tx_wihout_pilot,[],1);


% Error
error = rx_constellations - tx_constellations;

% L^2 norm for error between rx and tx
norm_error = norm(error);
fprintf('norm error =%d\n',norm_error/length(error));
if norm_error/length(error) < 0.2
    disp('tx data = rx data');
else
    disp('tx data != rx data');
end

t=1:1:length(out1);
t = t * sampling_period;

b=1:1:parameters.fft_size;

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
stem(lags,r)


figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(tx_constellations, 'o', 'color','red')
title('RX constellations')



%end