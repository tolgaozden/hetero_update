% gamma1_1=A1_inv*(B1+C1*beta1^2);
% gamma2_1=A1_inv*C1*(eye(numVar)-beta1^2)*alpha1;
% gamma3_1=A1_inv*D1;
% 
% gamma1_2=A2_inv*(B2+C2*beta1^2);
% gamma2_2=A2_inv*C2*(eye(numVar)-beta1^2)*alpha1;
% gamma3_2=A2_inv*D2;


gamma1_1=(A1-C1*beta1)\B1;
%gamma2_1=(A1-C1*beta1)\(C1*alpha1);
gamma2_1=(A1-C1*beta1)\(C1*(alpha1-beta1*alpha1));
gamma3_1=(A1-C1*beta1)\D1;

gamma1_2=(A2-C2*beta1)\B2;
%gamma2_2=(A2-C2*beta1)\(C2*alpha1);
gamma2_2=(A2-C2*beta1)\(C2*(alpha1-beta1*alpha1));
gamma3_2=(A2-C2*beta1)\D2;