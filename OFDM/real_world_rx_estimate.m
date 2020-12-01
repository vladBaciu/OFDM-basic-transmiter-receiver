out1 = Rx_OFDM_19_11_2020(1:19865);

rx_constellations = OFDM_rx(parameters,out1);
tx_wihout_pilot = frequencyDomain_symbols;
tx_wihout_pilot(pilot_interval_index(1:end),:) = [];
tx_constellations = reshape(tx_wihout_pilot,[],1);;


% Error
error = rx_constellations - tx_constellations;

% L^2 norm for error between rx and tx
norm_error = norm(error);
fprintf('norm error =%d\n',norm_error/length(error));
if norm_error/length(error) < 0.03
    disp('tx data = rx data');
else
    disp('tx data != rx data');
end

t=1:1:length(out1);
t = t * sampling_period;

b=1:1:parameters.fft_size;
figure
plot(b,real(ch))

figure
plot(t,real(out1))
title('Time domain data')
xlabel('Time (s)')
ylabel('Amplitude')
legend('Rx signal')

figure
plot(rx_constellations, 'o', 'color','blue')
%hold on
%plot(tx_constellations, 'o', 'color','red')
title('RX constellations')