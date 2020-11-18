function [tx_data] = OFDM_tx(parameters,frequencyDomain_symbols)
    %fs = N_FFT * Δf
    sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
    sampling_period= sampling_frequency^-1;
    cyclicPrefix_length=ceil(parameters.cyclicPrefix_us/sampling_period);
    %cyclicPrefix_length = round(parameters.fft_size/16);
    timeDomain_symbols=zeros(parameters.fft_size + cyclicPrefix_length, parameters.number_symbols);
    
    Nd = 50;
    t_interference = rand(Nd,1)-0.5+j*( rand(Nd,1)-0.5);
    
    if parameters.use_convolutional_code
        size = parameters.number_subcarriers;
    else
        size = parameters.number_subcarriers/2;
    end
    %frequency to time domain
    inverse_input = zeros(parameters.fft_size, 1);
    for k = 1:parameters.number_symbols
        frequencyDomain_symbolSet = frequencyDomain_symbols(:, k);
        inverse_input(2:size + 1) = ...
                                frequencyDomain_symbolSet(size + 1:end);
        %convert the discrete time sequence into the continouse time sequence
        %(make the discrete sequence like a continuouse sequence by padding
        % with 0)
        inverse_input(end - size + 1 :end) = ...
                                frequencyDomain_symbolSet(1:size);
                                            
        tx_data_channel(:,k) = inverse_input;
    end
     
        tx_data_without_cp = ifft(tx_data_channel);
         
    for k = 1:parameters.number_symbols    
        %add cyclic prefix
        tx_data_with_cp = zeros(length(tx_data_without_cp(:,k)) + cyclicPrefix_length,1);
        tx_data_with_cp(cyclicPrefix_length+1:end) = tx_data_without_cp(:,k);
        tx_data_with_cp(1:cyclicPrefix_length)=tx_data_without_cp(end-cyclicPrefix_length+1:end,k);
        tx_data(:,k) = [t_interference' tx_data_with_cp']';
    end
        tx_data=reshape(tx_data,[],1);%parallel to serial conversion
        
end