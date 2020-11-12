% main.m
% 22.10.2020
% 1.2 OFDM now can handle a number of symbols greater than 1 - Vlad 
% 1.3 Implemented dynamic cyclic prefix and pilot tone insertion - Vlad
% 1.4 ...

% found this SS - CPL table on a github example. 
% Intuitively I can understand the relation between SS - CPL but not how
% the CPL values were determined. Take it as it is now.
close all

subcarrier_spacings  = [15 30 60 120 240];
cp_lengths_us_normal = [4.69 2.34 1.17 0.57 0.29]; % length of cp in microseconds for each numerology

parameters.number_subcarriers = 90;
parameters.subcarrier_spacing = 30000; %  subcarrier spacing Hz
parameters.number_symbols = 10;
%Possible values: 128 512 1024 2048
parameters.fft_size = 2^ceil(log2(parameters.number_subcarriers));
parameters.cyclicPrefix_us=3.2*1e-6;;
parameters.pilot_frequency = 5 + 5*1i;
parameters.pilot_tones = 6;
parameters.use_convolutional_code = 0;
parameters.use_phase_and_CFO = 1;
parameters.use_CFO_preamble = 1;

%Possible values: 'QPSK','16QAM','64QAM'
constellation = '16QAM';
sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
sampling_period= sampling_frequency^-1;
parameters.cyclicPrefix_us=cp_lengths_us_normal(find(subcarrier_spacings==parameters.subcarrier_spacing/1000))*1e-6;;

%create frequency domain vector
frequencyDomain_symbols = zeros(parameters.number_subcarriers, parameters.number_symbols);

%do not change the sequence
preamble1=[0,1,-1,-1,1,1,-1,1,-1,1,-1,-1,-1,-1,-1,1,1,-1,-1,1,-1,1,-1,1,1,1,1];
preamble2=[1,1,1,1,-1,1,1,1,1,-1,-1,1,1,1,1,1,1,-1,1,-1,1,1,-1,-1,1,1];

preamble=[preamble1,zeros(1,11),preamble2];
preamble_td=ifft(preamble);
long_preamble=[preamble_td(33:64),preamble_td,preamble_td];


%get available qam symbols
[qam_alphabet, qam_gray_code] = QAM_mapping(constellation);

%get a number of random indexes from qam_alphabet 
random_index=ceil(length(qam_alphabet) * rand(size(frequencyDomain_symbols)));

%get randomn constellation symbols
frequencyDomain_symbols = qam_alphabet(random_index);

%map frequency symbols to gray code
for index_column=1:parameters.number_symbols
    frequencyDomain_symbols(:,index_column);
    for index_row=1:size(frequencyDomain_symbols,1)
        mapping(index_row,index_column) =  find(qam_alphabet==frequencyDomain_symbols(index_row,index_column));
        gray_mapping(index_row,index_column)= qam_gray_code(mapping(index_row,index_column));
    end
end

trellis = poly2trellis(7,[133 171]);
%code data using convolutional code
%map gray code to frequency symbols
for index=1:parameters.number_symbols
    
    data = de2bi(gray_mapping(:,index),'left-msb');
    data_stream = reshape(data',1,[]);
    code_data=convenc(data_stream,trellis);
    code_data = reshape(code_data,size(data,2),[]);
    code_data = code_data';
    for index_row=1:length(code_data)
        dec_symbols(index_row,index) = bi2de(code_data(index_row,:),'left-msb');
        frequency_coded_symbols(index_row,index) = qam_alphabet(find(qam_gray_code==dec_symbols(index_row,index)));
    end
end


pilot_interval = round(parameters.number_subcarriers/parameters.pilot_tones)-mod(parameters.number_subcarriers,parameters.pilot_tones);
pilot_interval_index=[1:pilot_interval:parameters.number_subcarriers];
frequencyDomain_symbols(pilot_interval_index(1:end),:)=parameters.pilot_frequency;
out = OFDM_tx(parameters,frequencyDomain_symbols);
out = out + 0.021 * randn(size(out));

% TBD - multipath channel and channel estimation
[fade_signal,ch] = multi_rayleigh(out,parameters.fft_size);
fade_signal = fade_signal(1:end-8);


frequency_offset = 5000;
phase_offset = 20;

hPFO = comm.PhaseFrequencyOffset('FrequencyOffset', frequency_offset, ...
                                 'PhaseOffset', phase_offset, ... 
                                 'SampleRate', parameters.number_symbols/sampling_period);
                             
long_preamble = step(hPFO,long_preamble); 


hPFO = comm.PhaseFrequencyOffset('FrequencyOffset', frequency_offset, ...
                                 'PhaseOffset', phase_offset, ... 
                                 'SampleRate', parameters.number_symbols/sampling_period);
out = step(hPFO,out);

long_preamble = fft(long_preamble);

if (parameters.use_CFO_preamble == 1)
    f_est = OFDM_estimate_CFO_preamble(long_preamble,sampling_frequency);
else
    f_est = 0;
end

rx_constellations = OFDM_rx(parameters,out,f_est);
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

t=1:1:length(out);
t = t * sampling_period;

b=1:1:parameters.fft_size;
figure
plot(b,real(ch))

figure
plot(t,real(out))
grid on
title('Time domain data')
xlabel('Time (s)')
ylabel('Amplitude')

figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(tx_constellations, 'o', 'color','red')
title('TX/RX constellations')