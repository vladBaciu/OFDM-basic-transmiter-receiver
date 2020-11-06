function [alphabet_out, gray_out] = QAM_mapping(modulation)
    
    modulation_type = {'QPSK','16QAM','64QAM'};
    constellaton_points_list = [4 16 64];
    
    
    modulation_index = find(strcmp(modulation_type, modulation));
    constellaton_points=constellaton_points_list(modulation_index);
    
    %create complex data d=I+jQ
    I_channel = -(sqrt(constellaton_points)-1):2:(sqrt(constellaton_points)-1);
    Q_channel = flip(I_channel);
    index = 1;
    for k=1:length(I_channel)
        for j=1:length(Q_channel)
            qam_alphabet(index) = I_channel(k) + 1j*Q_channel(j);
            index=index+1;
        end
    end
    
    b=(0:length(qam_alphabet)-1);
    b = de2bi(b,'left-msb');
    g(1,:) = b(1,:);
    for i = 1:length(qam_alphabet)
        g(i,1) = b(i,1);
        for j=2:size(b,2)
            g(i,j) = xor (b(i,j-1),b(i,j));
        end
    end
    dec = bi2de(g,'left-msb');
    reverse_flag = 0;
    index = (1:4:length(qam_alphabet))
    for i=1:sqrt(length(qam_alphabet))
       
       temp = dec(index(i): i*sqrt(length(qam_alphabet)));
       
       if(reverse_flag==1)
           temp = flip(temp);
       end
       gray_modulation(index(i): i*sqrt(length(qam_alphabet))) = temp;
       reverse_flag = not(reverse_flag);
    end
    alphabet_out = qam_alphabet(:);
    gray_out = gray_modulation(:);
%     figure
%     plot(out, 'o')
%     title('TX Constellations') 
end