package.path = "../?.lua;"..package.path;

require("p5")

function setup()
    rectMode(RADIUS); -- Set rectMode to RADIUS
    fill(255); -- Set fill to white
    rect(50, 50, 30, 30); -- Draw white rect using RADIUS mode
    
    rectMode(CENTER); -- Set rectMode to CENTER
    fill(100); -- Set fill to gray
    rect(50, 50, 30, 30); -- Draw gray rect using CENTER mode
end


go({width=640, height=480, title="test_p5_rectmode2"});
