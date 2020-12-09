% lg_subcarier spacing_pilot tones_number symbols 
% tx_data_12_08_lg_7500_8_50
% tx_data_12_08_lg_7500_11
% tx_data_12_08_s_7500_8_20
% tx_data_12_08_s_15000_8_20
% tx_data_12_08_s_15000_8_50
% tx_data_12_08_s_30000_8_50
% tx_data_12_08_short_period
% tx_data_12_08
% tx_data_old

fft_size = 2^ceil(log2(90));
fs = fft_size * 30000;
sampling_period= fs^-1;

tx_data_sent = load('tx_data.mat')
tx_data_sent = tx_data_sent.save_data_tx;

t=1:1:length(tx_data_sent);
t = t * sampling_period;
figure
plot(t,real(tx_data_sent))

fs = 20e6;

Y = fft(tx_data_sent');

P2 = abs(Y/length(tx_data_sent));
P1 = P2(1:length(tx_data_sent)/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:(length(tx_data_sent)/2))/length(tx_data_sent);
plot(f,P1)