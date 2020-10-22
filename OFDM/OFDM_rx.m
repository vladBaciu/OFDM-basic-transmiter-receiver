function [rx_data] = OFDM_rx(parameters,timeDomain_data)
    
    rx_buffer = zeros(parameters.number_subcarriers, parameters.number_symbols);
    sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
    sampling_period= sampling_frequency^-1;
    cyclicPrefix_length=ceil(parameters.cyclicPrefix_us/sampling_period);
    symbol_length = parameters.fft_size + cyclicPrefix_length;
    
    pilot_interval = round(parameters.number_subcarriers/parameters.pilot_tones)-mod(parameters.number_subcarriers,parameters.pilot_tones);
    pilot_interval_index=[1:pilot_interval:parameters.number_subcarriers];
    
    timeDomain_data=reshape(timeDomain_data,parameters.fft_size+cyclicPrefix_length,[]);
    timeDomain_data=timeDomain_data(cyclicPrefix_length+1:end,:);
    frequency_symbols = fft(timeDomain_data);
    for k = 1: parameters.number_symbols
        
        rx_out = zeros(parameters.number_subcarriers, 1);
        rx_out(1:parameters.number_subcarriers/2) = frequency_symbols(end - parameters.number_subcarriers/2 + 1:end,k);
        rx_out(parameters.number_subcarriers/2+1:end) = frequency_symbols(2:parameters.number_subcarriers/2+1,k);
        rx_buffer(:,k) = rx_out;
    end
    
    %eliminate pilot frequencies
    rx_buffer(pilot_interval_index(1:end),:) = [];
    
    rx_data=reshape(rx_buffer,[],1);%parallel to serial conversion;
end