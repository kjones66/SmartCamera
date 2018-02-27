function [] = saveKinectPictures(d,frame)
      saveas(figure, fullfile('T:\Kinect Data','asdf.jpg'))
      pic = sprintf('%d_%d_%d_%d.jpg',d.AbsTime(2),...
           d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
      saveas(figure(1),fullfile('T:\Kinect Data',pic));
      %frame = getsnapshot(vid);

      figure2 = image(frame);
      image(frame);
      pic = sprintf('%d_%d_%d_%dimage.jpg',d.AbsTime(2),...
           d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
      saveas(figure(1),fullfile('T:\Kinect Data',pic));
       close (figure(2));
end

