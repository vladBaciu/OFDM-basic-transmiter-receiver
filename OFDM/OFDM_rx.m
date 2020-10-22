function [rx_data] = OFDM_rx(parameters,timeDomain_data)
    
    rx_buffer = zeros(parameters.number_subcarriers, parameters.number_symbols);
    cyclicPrefix_length = round(parameters.fft_size/16);
    symbol_length = parameters.fft_size + cyclicPrefix_length;
    
    
    timeDomain_data=reshape(timeDomain_data,parameters.fft_size+cyclicPrefix_length,[]);
    timeDomain_data=timeDomain_data(cyclicPrefix_length+1:end,:);
    frequency_symbols = fft(timeDomain_data);
    for k = 1: parameters.number_symbols
        
        rx_out = zeros(parameters.number_subcarriers, 1);
        rx_out(1:parameters.number_subcarriers/2) = frequency_symbols(end - parameters.number_subcarriers/2 + 1:end,k);
        rx_out(parameters.number_subcarriers/2+1:end) = frequency_symbols(2:parameters.number_subcarriers/2+1,k);
        rx_buffer(:,k) = rx_out;
    end
    
    rx_data=reshape(rx_buffer,[],1);%parallel to serial conversion;
end