% main.m
% 10/10/2020 

parameters.number_subcarriers = 90;
parameters.subcarrier_spacing = 322000; %  subcarrier spacing
parameters.number_symbols = 2;
%Possible values: 128 512 1024 2048
parameters.fft_size = 2048;
parameters.cyclicPrefix_us=3.2*1e-6;;
parameters.pilot_frequency = 5 + 5*1i;
parameters.pilot_tones = 6;
%Possible values: 'QPSK','16QAM','64QAM'
constellation = '16QAM';


%create frequency domain vector
frequencyDomain_symbols = zeros(parameters.number_subcarriers, parameters.number_symbols);
%get available qam symbols
qam_alphabet = QAM_mapping(constellation);
%get a number of random indexes from qam_alphabet 
random_index=ceil(length(qam_alphabet) * rand(size(frequencyDomain_symbols)));
%get randomn constellation symbols
frequencyDomain_symbols = qam_alphabet(random_index);
pilot_interval = round(parameters.number_subcarriers/parameters.pilot_tones)-mod(parameters.number_subcarriers,parameters.pilot_tones);
pilot_interval_index=[1:pilot_interval:parameters.number_subcarriers];
frequencyDomain_symbols(pilot_interval_index(1:end),:)=parameters.pilot_frequency;
out = OFDM_tx(parameters,frequencyDomain_symbols);
out = out + 0.001 * randn(size(out));

rx_constellations = OFDM_rx(parameters,out);
tx_constellations = reshape(frequencyDomain_symbols,[],1);;


% Error
error = rx_constellations - tx_constellations;
% L^2 norm for error between rx and tx
norm_error = norm(error);
if norm_error/length(error) < 0.03
    disp('tx data = rx data');
else
    disp('tx data != rx data');
end

figure
plot(real(out))
grid on
title('TD')
xlabel('S')
ylabel('A')

figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(frequencyDomain_symbols, 'o', 'color','red')
title('TX/RX constellations')