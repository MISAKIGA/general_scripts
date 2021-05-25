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
    cookie = 'UM_distinctid=1784984bc0214d-013a2949a9b0d-53e356a-100200-1784984bc036e8; Hm_lvt_6d8d9a52ae50c99e6981efe4e12e0d14=1621874407; automaticLogon=true; username=15602203133; pwd=Ts8D1EU1HLslash3QcAYUNW+Pw==; JSESSIONID=C0CE1258C1252805FCA70CB68C0470EF; CNZZDATA1273545537=1550963213-1583310773-%7C1621881408; _uc_t_=686026%3B15602203133%3B2f940803f7584aeabb33c5a5f227fd68%3Bbxg%3B1621970731941; zg_did=%7B%22did%22%3A%20%22170a4f1f5961f8-02a802dcb16255-67e1b3f-1fa400-170a4f1f5972ec%22%7D; zg_359878badcb44bf88a748ad7859455ea=%7B%22sid%22%3A%201621884331105%2C%22updated%22%3A%201621884553863%2C%22info%22%3A%201621874406136%2C%22superProperty%22%3A%20%22%7B%5C%22platform%5C%22%3A%20%5C%22PCS%5C%22%7D%22%2C%22platform%22%3A%20%22%7B%7D%22%2C%22utm%22%3A%20%22%7B%7D%22%2C%22referrerDomain%22%3A%20%22%22%2C%22landHref%22%3A%20%22http%3A%2F%2Fstu.ityxb.com%2Flearning%2F95af39e948ff46b9a173a1ff8c55a296%2Fpreview%2Flist%22%2C%22cuid%22%3A%20%22acba544870c34f6cb26d46c25c9d4de7%22%2C%22zs%22%3A%200%2C%22sc%22%3A%200%2C%22firstScreen%22%3A%201621884331105%7D; Hm_lpvt_6d8d9a52ae50c99e6981efe4e12e0d14=1621884554'
    
    # 输入你要下载的科目ID
    subject_id = '091fb4bdc4974caeaae96515ada97883'

    preview_info_url = 'http://stu.ityxb.com/back/bxg/preview/info?previewId=' + subject_id

    subject_title_name(preview_info_url, cookie)

    print('DONE!!!!!!!!!!!!!!!!!!!!! 下载完成辣!!!!!!!!!!!')
    # url = 'https://new-bxgstorge.boxuegu.com/bxg/textbook/093/afterClassVideo/093001002.mp4'
    #file_path ='C:/Users/MISAKIGA/Desktop/学习视频/'
    #download_viedo_service(file_path, url)