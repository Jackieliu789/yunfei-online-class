package com.yunfeisoft.business.model;

import com.applet.base.ServiceModel;
import com.applet.sql.record.TransientField;
import com.applet.utils.DateUtils;
import com.yunfeisoft.business.enums.ClassStatusEnum;
import com.yunfeisoft.business.enums.ShelfStatusEnum;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.Date;

/**
 * ClassName: PmsLiveCourse
 * Description: 直播课堂表
 *
 * @Author: Jackie liu
 * Date: 2020-03-29
 */
@Entity
@Table(name = "PMS_LIVE_COURSE")
public class PmsLiveCourse extends ServiceModel implements Serializable {

    /**
     * Field serialVersionUID: 序列号
     */
    private static final long serialVersionUID = 1L;

    /**
     * 名称
     */
    @Column
    private String name;

    /**
     * 简介
     */
    @Column
    private String intro;

    /**
     * 封面路径
     */
    @Column
    private String coverPath;

    /**
     * 上架状态(1上架，2下架)
     */
    @Column
    private Integer shelfStatus;

    /**
     * 开始时间
     */
    @Column
    private Date beginDate;

    /**
     * 结束时间
     */
    @Column
    private Date endDate;

    /**
     * 上课状态(1未开始，2授课中，3已结束)
     */
    @Column
    private Integer classStatus;

    /**
     * 老师id
     */
    @Column
    private String teacherId;

    /**
     * 邀请码
     */
    @Column
    private String inviteCode;

    /**
     * 直播间id
     */
    @Column
    private Integer roomId;

    /**
     * 类别
     */
    @Column
    private Integer type;

    @TransientField
    private String teacherName;
    private String content;

    private String[] userIds;

    public String getClassStatusStr() {
        return ClassStatusEnum.valueOf(classStatus);
    }

    public String getShelfStatusStr() {
        return ShelfStatusEnum.valueOf(shelfStatus);
    }

    public String getBeginDateStr() {
        if (beginDate == null) {
            return null;
        }
        return DateUtils.dateToString(beginDate, "yyyy-MM-dd HH:mm");
    }

    public String getEndDateStr() {
        if (endDate == null) {
            return null;
        }
        return DateUtils.dateToString(endDate, "yyyy-MM-dd HH:mm");
    }

    public String getBeginDateStr2() {
        if (beginDate == null) {
            return null;
        }
        return DateUtils.dateToString(beginDate, "MM/dd HH:mm");
    }

    public String getEndDateStr2() {
        if (endDate == null) {
            return null;
        }
        return DateUtils.dateToString(endDate, "HH:mm");
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }

    public String getCoverPath() {
        return coverPath;
    }

    public void setCoverPath(String coverPath) {
        this.coverPath = coverPath;
    }

    public Integer getShelfStatus() {
        return shelfStatus;
    }

    public void setShelfStatus(Integer shelfStatus) {
        this.shelfStatus = shelfStatus;
    }

    public Date getBeginDate() {
        return beginDate;
    }

    public void setBeginDate(Date beginDate) {
        this.beginDate = beginDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Integer getClassStatus() {
        return classStatus;
    }

    public void setClassStatus(Integer classStatus) {
        this.classStatus = classStatus;
    }

    public String getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(String teacherId) {
        this.teacherId = teacherId;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String[] getUserIds() {
        return userIds;
    }

    public void setUserIds(String[] userIds) {
        this.userIds = userIds;
    }

    public enum LiveCourseTypeEnum {

        SINGLE(1, "单主播"),
        MULTI(2, "多主播");

        private int value;
        private String label;

        private LiveCourseTypeEnum(int value, String label) {
            this.value = value;
            this.label = label;
        }

        public static String valueOf(Integer value) {
            if (value == null) {
                return null;
            }
            for (LiveCourseTypeEnum loop : LiveCourseTypeEnum.values()) {
                if (value == loop.getValue()) {
                    return loop.getLabel();
                }
            }
            return null;
        }

        public int getValue() {
            return value;
        }

        public String getLabel() {
            return label;
        }

    }
}