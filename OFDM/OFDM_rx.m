function [rx_data] = OFDM_rx(parameters,timeDomain_data,f_est)
    
    rx_buffer = zeros(parameters.number_subcarriers, parameters.number_symbols);
    sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
    sampling_period= sampling_frequency^-1;
    cyclicPrefix_length=ceil(parameters.cyclicPrefix_us/sampling_period);
    symbol_length = parameters.fft_size + cyclicPrefix_length;
    
    pilot_interval = round(parameters.number_subcarriers/parameters.pilot_tones)-mod(parameters.number_subcarriers,parameters.pilot_tones);
    pilot_interval_index=[1:pilot_interval:parameters.number_subcarriers];
    
    
sig_w = zeros(2,cyclicPrefix_length); % Initialize the two sliding window buffers
STOs = [0]; % Initialize the STO buffer
Nsym = parameters.fft_size + cyclicPrefix_length;
m = 0;

for n=1:length(timeDomain_data)
   sig_w(1,:) = [sig_w(1,2:end) timeDomain_data(n)]; % Update signal window 1
   m = n-parameters.fft_size;
   temp = [0];
   if m>0
     sig_w(2,:)=[sig_w(2,2:end) timeDomain_data(m)]; % Update signal window 2
     den = norm(sig_w(1,:))*norm(sig_w(2,:));
     corr(n) = abs(sig_w(1,:)*sig_w(2,:)')/den;
    
     if corr(n)>0.93 & (corr(n) > corr(n-1))
       if(length(STOs) > 1)
         
         if(m>STOs(end)+Nsym-15)  
             STOs=[STOs  m]; % List the estimated STO
         end
       else
             STOs=[STOs  m]; % List the estimated STO
       end  
     end
   end
end

Estimated_STOs = STOs(2:end);
    
    
    timeDomain_data=reshape(timeDomain_data,parameters.fft_size+cyclicPrefix_length,[]);
    timeDomain_data=timeDomain_data(cyclicPrefix_length+1:end,:);
    frequency_symbols = fft(timeDomain_data);
    for k = 1: parameters.number_symbols
        
        rx_out = zeros(parameters.number_subcarriers, 1);
        rx_out(1:parameters.number_subcarriers/2) = frequency_symbols(end - parameters.number_subcarriers/2 + 1:end,k);
        rx_out(parameters.number_subcarriers/2+1:end) = frequency_symbols(2:parameters.number_subcarriers/2+1,k);
        rx_buffer(:,k) = rx_out;
    end
    
    % channel estimation needs to be insertet before phase tracking and CFO
    % estimation
    
    % Method 1
    % we can use the H function returned from the multi_rayleigh function 
    % the question is how.
    
    % add one more parameter for the function - the channel from multi
    % function
    % H 1x128 , the data is 1300x1
    % data=data3(data(1:end),:)./H;
    
   
    % Method 2 asd = rx_buffer(pilot_interval_index(1:end),:)
    % pilot tones: rx_buffer(pilot_interval_index(1:end),:)
    % second method - to extract another H like in the Physical example
    % using the pilot tones
    % the same as in Physical example:
    % rx_buffer 90x10  -> 10 * 6 = 60 pilot tones;
    % Only for 90x1 
    % data3=fft_data(1:N_fft,:); 
    % Rx_pilot=data3(P_f_station(1:end),:); %Received pilot
    % h=Rx_pilot./pilot_seq; 
    % H=interp1( P_f_station(1:end)',h,data_station(1:end)','linear','extrap');%Piecewise linear interpolation: The function value at the interpolation point is predicted by the linear function connecting its nearest two sides. Use the specified interpolation method to calculate the function value for the interpolation points beyond the known point set
    % Channel correction for each column ->
    % data_aftereq=data3(data_station(1:end),:)./H;
    
    % Insert your code here
    

    if(parameters.use_phase_and_CFO == 1)
        rx_buffer = OFDM_phase_tracking(parameters.number_subcarriers,parameters.number_symbols,pilot_interval_index(1:end), ...
                                        rx_buffer,parameters);
         
        if(f_est == 0)
            rx_buffer = OFDM_estimate_CFO(parameters,rx_buffer,pilot_interval_index(1:end));
        else
            comp_phase = exp(1j*f_est*2*pi*[1:length(rx_buffer)]*sampling_period);
            rx_buffer = rx_buffer .* comp_phase';
        end                           
    end
    
   
    
    %eliminate pilot frequencies
    rx_buffer(pilot_interval_index(1:end),:) = [];
     
    rx_data=reshape(rx_buffer,[],1);%parallel to serial conversion;
    
    
   
end