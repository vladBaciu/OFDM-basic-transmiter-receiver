 Options = tfestOptions;           
 Options.Display = 'on';           
 Options.WeightingFilter = [];     

                                   


response = load('output/tf_response.mat');
response = response.tf_data;
tf_t = 1:1:length(response);
figure
plot(tf_t,real(response))
hold on
input(1:18)=0; input(19:length(response)) = 0.5;
input = input';
plot(tf_t,input)

mydata = iddata(response,input);                                 
tf3 = tfest(mydata, 3, 1, Options);
fast = 0.1; 
Ginv = (1/tf3)*tf(1,[fast^2 2*fast 1])
syms s
sys = tf(tf3.Numerator,tf3.Denominator);
F =  -(7.69e-05+0.0001073i)* s + (1.909e-07-2.157e-07i)/...
s^3 + (0.006154-0.05171i)* s^2 + (0.0003081-5.634e-05i) *s + (3.449e-06-2.117e-05i)
 
IF = ilaplace(F)



X_test=fft(input,parameters.fft_size);
Y_test=fft(response,parameters.fft_size);
H1=Y_test/X_test;
h=ifft(H1,6);