 %% PCA_plot

[coeff,score,latent] = pca(imgobj.mat2D);
figure
bar(latent)

Comp_num=5;

figure
for comp=1:Comp_num
    subplot(Comp_num,2,2*(comp)-1)
    plot(score(:,comp))
    xlabel('Time')
     subplot(Comp_num,2,2*(comp))
    stem(coeff(:,comp))
     xlabel('Neuron')
end

figure, imagesc(imgobj.mat2D), colorbar() 
%%
Cluster_num=5;
Idx = kmeans(coeff(:,1:3),Cluster_num);
COLOR=jet(6);
figure
for i=1:Cluster_num
    XX=find(Idx==i);
    plot3(coeff(XX,1),coeff(XX,2),coeff(XX,3),'o','color',COLOR(i,:));hold on
end
grid on
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

%%%%%
[~, sortIdx] = sort(Idx);
corA = corr(imgobj.mat2D(:,sortIdx));
figure
subplot(1,2,1)
imagesc(corA)

subplot(1,2,2)
imagesc(imgobj.mat2D(:,sortIdx)')
