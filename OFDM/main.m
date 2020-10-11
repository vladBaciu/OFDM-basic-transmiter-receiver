parameters.number_subcarriers = 90;
parameters.subcarrier_spacing = 322000; % 15kHz subcarrier spacing
parameters.number_symbols = 1;
%Possible values: 128 512 1024 2048
parameters.fft_size = 2048;
parameters.cyclicPrefix_us=3.2*1e-6;;
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

out = OFDM_tx(parameters,frequencyDomain_symbols);
out = out + 0.005 * randn(size(out));

rx_constellations = OFDM_rx(parameters,out);
tx_constellations = frequencyDomain_symbols;
% Error
error = rx_constellations - tx_constellations;

if norm(error)/length(error) < 0.03
    disp('Success! RX Data = TX Data');
else
    disp('Something may not be correct...');
end

figure
plot(real(out))
grid on
title('Time Domain View')
xlabel('Sample')
ylabel('Magnitude')

figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(frequencyDomain_symbols, 'o', 'color','red')
title('TX')