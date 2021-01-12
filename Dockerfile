FROM archiveteam/warrior-dockerfile

RUN pip3 install setuptools wheel
RUN pip3 install seesaw zstandard requests warcio
