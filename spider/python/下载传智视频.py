import requests
import json
import os

def download_viedo_service(file_path, url):
    
    try:
        
        # 代理浏览器请求头
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"}
        pre_content_length = 0

		# 循环接收视频数据
        while True:# 若文件已经存在，则断点续传，设置接收来需接收数据的位置    
            if os.path.exists(file_path):
                headers['Range'] = 'bytes=%d-' % os.path.getsize(file_path)
            res = requests.get(url, stream=True, headers=headers)
            content_length = int(res.headers['content-length'])
			# 若当前报文长度小于前次报文长度，或者已接收文件等于当前报文长度，则可以认为视频接收完成
            if content_length < pre_content_length or (os.path.exists(file_path) and os.path.getsize(file_path) >= content_length):
                break
            pre_content_length = content_length
			# 写入收到的视频数据
            with open(file_path, 'ab') as file:
                file.write(res.content)
                file.flush()
                print('receive data，file size : %d   total size:%d' % (os.path.getsize(file_path), content_length))
    except Exception as e:
        dic = {'url':url, 'file_path':file_path}
        print("下载失败:", dic)

def specifying_download(folder_path, chapters, user_cps=None):

    local_path = os.path.dirname(__file__)
    folder_path = os.path.join(local_path, folder_path)

    if not os.path.exists(folder_path):
        os.mkdir(folder_path)

    if user_cps is None:
        user_cps = range(len(chapters))

    for i in user_cps:
        subchapter_point_name = chapters[i]['chapter']['point_name']
        print(subchapter_point_name)
        subchapter_points = chapters[i]['points']
        
        # 创建章节文件夹
        chapter_path = os.path.join(folder_path, subchapter_point_name)
        if not os.path.exists(chapter_path):
            os.mkdir(chapter_path)

        # 遍历章节视频
        for subchapter in subchapter_points:
            file_name = subchapter['point_name'] + '.MP4'
            video_url = subchapter['video_url']

            file_path = os.path.join(chapter_path, file_name)

            print('准备下载{0}, 下载地址：{1}'.format(file_path, video_url))

            # 下载视频
            #TODO：　多线程下载
            download_viedo_service(file_path, video_url)

def analysis_download(json_content):

    # 解析字符串
    preview = json_content['preview']
    chapters = json_content['chapters']


    print('++++++ 简易下载器 +++++++++')
    previewName = preview['previewName']
    print('[{0}] 一共有{1}章'.format(previewName, len(chapters)))
    print('全部下载按下任意键, 选择章节下载输入 0 ')
    menu = input()

    if menu == '0':
        cpstr = ''
        for i in range(len(chapters)):
            cpstr += ' {0} :{1} '.format(i, chapters[i]['chapter']['point_name'])

        print('请选择您要下载的章节, 例如 0,1,2,3 多个章节以逗号分割!')
        print(cpstr)
        cpstr = input()
        print('准备下载一下章节： ' , cpstr)
        cpstrs = cpstr.replace('，',',').split(',')
        print(cpstrs[1])
        # 转换为整数数组
        cpstrs = list(map(int, cpstrs))
        specifying_download(previewName, chapters, cpstrs)
    else:
        specifying_download(previewName, chapters)


def subject_title_name(url, cookie):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
        "Cookie": cookie,
        "Host": "stu.ityxb.com",
        "Connection": "keep-alive"
    }
    res = requests.get(url, stream=True, headers=headers)
    str_content = res.content
    json_content = json.loads(str_content)
    
    state =  str(json_content['success']).lower()

    if state == 'true':

        analysis_download(json_content['resultObject'])
    else:
        print('响应信息返回错误(如果是needLogin请检查你的cookie是否为最新): {0}'.format(json_content['resultObject']))

if __name__ == '__main__':
    
    # 拿到自己的账号COOKIE
    cookie = ''
    # 输入你要下载的课程ID
    subject_id = ''

    if cookie == '' or subject_id == '':
    	print('请输入你的Cookie，可以在浏览器打开网站按 F12 查看：')
    	cookie = input()

    	print('请输入你要下载的课程ID，详细教程在  ：')
    	subject_id = input()

    preview_info_url = 'http://stu.ityxb.com/back/bxg/preview/info?previewId=' + subject_id

    subject_title_name(preview_info_url, cookie)

    print('DONE!!!!!!!!!!!!!!!!!!!!! 下载完成辣!!!!!!!!!!!')
    # url = 'https://new-bxgstorge.boxuegu.com/bxg/textbook/093/afterClassVideo/093001002.mp4'
    #file_path ='C:/Users/MISAKIGA/Desktop/学习视频/'
    #download_viedo_service(file_path, url)